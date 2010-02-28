/* 
 | direct JS -> C port of encodeGeoHash (ugly formatting and all) from:
 | http://github.com/davetroy/geohash-js/tree/master/geohash.js
 | no decoding or adjacency finding implemented (or required) yet
 */

int BITS[] = {16, 8, 4, 2, 1};
char BASE32[] = "0123456789bcdefghjkmnpqrstuvwxyz";

void encodeGeoHash(float latitude, float longitude, char *geohash_buf) {
        int is_even=1;
        double lat[4] = {0};
        double lon[4] = {0};
        int bit=0;
        int ch=0;
        int precision = 12;  /* static precision. no dynamic short fanciness */
        int geohash_length = 0;
        double mid = 0;

        lat[0] = -90.0;  lat[1] = 90.0;
        lon[0] = -180.0; lon[1] = 180.0;

        while (geohash_length < precision) {
          if (is_even) {
                        mid = (lon[0] + lon[1]) / 2;
            if (longitude > mid) {
                                ch |= BITS[bit];
                                lon[0] = mid;
            } else
                                lon[1] = mid;
          } else {
                        mid = (lat[0] + lat[1]) / 2;
            if (latitude > mid) {
                                ch |= BITS[bit];
                                lat[0] = mid;
            } else
                                lat[1] = mid;
          }

                is_even = !is_even;
          if (bit < 4)
                        bit++;
          else {
                        geohash_buf[geohash_length] = BASE32[ch];
                        geohash_length++;
                        bit = 0;
                        ch = 0;
          }
        }
}

