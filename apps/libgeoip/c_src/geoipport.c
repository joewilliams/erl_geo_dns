#include "GeoIP.h"
#include "GeoIPCity.h"
#include "erl_interface.h"

typedef unsigned char byte;

#define fprintf(a,b, ...) 
//#define fprintf(a,b, ...) fprintf(a, b, __VA_ARGS__)

#define erl_mk_string(x) erl_mk_string(((x) == NULL) ? "" : x)

int read_cmd(byte *);
int write_cmd(byte *, int);
void encodeGeoHash(float, float, char *);

void lookup_city(GeoIP *geoip, unsigned int ip) {
  ETERM *country_code, *region, *state, *city, *postal_code, *lat, *lng, *rec;
  ETERM *erl_geohash;
  ETERM *tuplep;
  ETERM *result_arr[9] = {0};
  GeoIPRecord *gir = NULL;
  char geohash[16] = {0}; /* auto null terminate the geohash string */
  int tuple_len = 0;
  byte buffer[1024] = {0};

  gir = GeoIP_record_by_ipnum(geoip, ip);
  if (gir != NULL) {
fprintf(stderr, "NOT NULL\n");
fprintf(stderr, "values: %s %s %s %s %s\n", gir->country_code, gir->region, gir->city, gir->postal_code, geohash);
    country_code = erl_mk_string(gir->country_code);
    region       = erl_mk_string(gir->region);
    state        = erl_mk_string(GeoIP_region_name_by_code(gir->country_code, gir->region)),
    city         = erl_mk_string(gir->city);
    postal_code  = erl_mk_string(gir->postal_code);
    lat          = erl_mk_float(gir->latitude);
    lng          = erl_mk_float(gir->longitude);
    encodeGeoHash(gir->latitude, gir->longitude, geohash);
    erl_geohash  = erl_mk_string(geohash);
    rec = erl_mk_atom("geoip");
    result_arr[0] = rec;
    result_arr[1] = country_code;
    result_arr[2] = region;
    result_arr[3] = state;
    result_arr[4] = city;
    result_arr[5] = postal_code;
    result_arr[6] = lat;
    result_arr[7] = lng;
    result_arr[8] = erl_geohash;
    tuplep = erl_mk_tuple(result_arr, 9);
  }
  else {
    tuplep = erl_mk_string("");
  }

  tuple_len = erl_encode(tuplep, buffer);
  write_cmd(buffer, tuple_len);
  erl_free_compound(tuplep); 

  if (gir != NULL) GeoIPRecord_delete(gir);
}



int main() {
  ETERM *ipp = NULL;
  GeoIP *gi = NULL;
  byte buf[512] = {0};  /* big enough */
  void (*lookup)(GeoIP *, unsigned int) = NULL;
  unsigned long allocated, freed;

  erl_init(NULL, 0);

  while (read_cmd(buf) > 0) {

    erl_eterm_statistics(&allocated, &freed);
    fprintf(stderr, "Allocated: %lu, Freed: %lu\n", allocated, freed);
    if ((ipp = erl_decode(buf)) == NULL) {
      ETERM *err = erl_mk_atom("decode_error");
      int len = erl_encode(err, buf);
      write_cmd(buf, len);
      erl_free_compound(err);
    }

    if (ERL_IS_UNSIGNED_INTEGER(ipp) != 0) {
    fprintf(stderr, "IS UNSIGNED INTEGER\n");
      (*lookup)(gi, ERL_INT_UVALUE(ipp));
    }
    else if (ERL_IS_INTEGER(ipp) != 0) {
    fprintf(stderr, "IS INTEGER\n");
      (*lookup)(gi, ERL_INT_VALUE(ipp));
    }
    else if (ERL_IS_LIST(ipp) != 0) {
    fprintf(stderr, "IS LIST\n");
      char *filename = erl_iolist_to_string(ipp);
      byte edition;
      if (gi) GeoIP_delete(gi);
      /* mmap the data file.  
           or GEOIP_MEMORY_CACHE to load the entire 15MB file all at once */
      gi = GeoIP_open(filename, GEOIP_MMAP_CACHE); 
      if (gi == NULL) {
        fprintf(stderr, "Error opening database\n");
        exit(1);
      }
     
      edition = GeoIP_database_edition(gi);
      if (edition == GEOIP_CITY_EDITION_REV0 || 
          edition == GEOIP_CITY_EDITION_REV1) {
        lookup = &lookup_city;
      }
      erl_free(filename);
    }
    else {
      ETERM *err = erl_mk_atom("bad_type");
      int len = erl_encode(err, buf);
      write_cmd(buf, len);
      erl_free_compound(err);
    }
    erl_free_compound(ipp);
  }
  fprintf(stderr, "LEAVING\n");
  GeoIP_delete(gi);

  return 0;
}
