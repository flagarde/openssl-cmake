 /*
 *
 * Test function for OpenSSL signature verification
 *
 * to build on OSX
 * g++ -g -lssl -std=c++11  main.cpp -o testECDSA -lcrypto -I/usr/local/Cellar/openssl/1.0.2p/include/
 *
 * to build on RPi
 * g++ -g -lssl -std=c++11  main.cpp -o testECDSA -lcrypto -s
 *
 * */

#include <iostream>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

//include OpenSSL headers
#include <openssl/sha.h>
#include <openssl/bn.h>
#include <openssl/hmac.h>
#include <openssl/ec.h>      // for EC_GROUP_new_by_curve_name, EC_GROUP_free, EC_KEY_new, EC_KEY_set_group, EC_KEY_generate_key, EC_KEY_free
#include <openssl/ecdsa.h>   // for ECDSA_do_sign, ECDSA_do_verify
#include <openssl/obj_mac.h> // for NID_secp192k1 NID_X9_62_prime256v1 NID_secp256k1 and other
#include <openssl/opensslv.h>

#define uchar unsigned char
using namespace std;
//function for signature verification
int verifySignature(const uchar* digest32, const char* sigr32, const char* sigs32 , const char* pubx32, const char* puby32) {

    EC_KEY    *eckey = NULL; //Elliptic Curve structure
    const EC_GROUP *group; //Group
    EC_POINT *pub_key; //Public key structure
    eckey = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1); //new ec key NID_X9_62_prime256v1
    group = EC_KEY_get0_group(eckey);
    pub_key = EC_POINT_new(group); //new pub key from group

    //prepare (concatenate) public_key from provided components
    string bufPubKey;
    bufPubKey.append("04"); //OpenSSL specific!
    bufPubKey.append(pubx32);
    bufPubKey.append(puby32);

    //Load Publick Key
    if (!EC_POINT_hex2point(group, bufPubKey.c_str(), pub_key, NULL)) {
        printf("EC_POINT_hex2point failed:\n");
    }

    EC_KEY_set_public_key(eckey, pub_key);
    if (!EC_KEY_check_key(eckey)) {
        printf("EC_KEY_check_key failed:\n");
    }

#if OPENSSL_VERSION_NUMBER < 0x10100000L
    /* OpenSSL 1.0.2 and below (old code) */
    //Create new ECDSA signature structure from provided s and r 32bytes components
    ECDSA_SIG * signature = ECDSA_SIG_new();
    BN_hex2bn(&signature->s, sigs32); //in reply from DC "s" is first part
    BN_hex2bn(&signature->r, sigr32); //in reply from DC "r" is second part

    //do verification and return results
    return ECDSA_do_verify(digest32, 32, signature, eckey);
#else
    /* OpenSSL 1.1.0 and above (new code) */
    //todo
    return 0;
#endif
}

//byte array to HEX string
static char buffTMP[256];
char hexmap[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
char * hexStr2(uchar * data, int len) {
    //memset(buffTMP, 0x00, sizeof(buffTMP));
    for (int i = 0; i < len; ++i) {
        buffTMP[2 * i]     = hexmap[(data[i] & 0xF0) >> 4];
        buffTMP[2 * i + 1] = hexmap[data[i] & 0x0F];
    }
    buffTMP[2 * len] = 0x00;
    return buffTMP;
}
char * hexStr3(uchar * data, int len) {
    //memset(buffTMP, 0x00, sizeof(buffTMP));
    for (int i = 0; i < len; ++i) {
        buffTMP[3 * i]     = hexmap[(data[i] & 0xF0) >> 4];
        buffTMP[3 * i + 1] = hexmap[data[i] & 0x0F];
        buffTMP[3 * i + 2] = ' ';
    }
    buffTMP[3 * len] = 0x00;
    return buffTMP;
}

int main() {
    cout << "ECDSA Test Engine  " << endl;

    uchar romid[8] = {0x4C,0x42,0xd6,0x05,0x00,0x00,0x00,0x9a}; //My Device ID
    uchar page0[32]; memset(page0, 0xFF, sizeof(page0));
    uchar buffer[32]; for(uchar x=0;x<32;x++) buffer[x]=x; //0,1 .. 31 //32bytes
    uchar page[1] = {0};
    uchar manid[2] = {0,0};
    uchar input_buff[75];
    uchar digest32[32];

    //concatenate message into input_buff
    memcpy(input_buff, romid, 8);
    memcpy(input_buff+8, page0, 32);
    memcpy(input_buff+8+32, buffer, 32);
    memcpy(input_buff+8+32+32, page, 1);
    memcpy(input_buff+8+32+32+1, manid, 2);

    //sha256 from our block of defined data
    SHA256(input_buff, 75, digest32);

    printf(">>> BUFFER = %s\n", hexStr2(input_buff,75));
    printf(">>> SHA256 = %s\n", hexStr2(digest32,32));

    char sigs32[] = "9094e47bb0b50bf5094972a8e42179b1a6d0580a92b74154d767ddd2d86b1780"; //sample signature s (first arrived)
    char sigr32[] = "95772897b5cd7be190466059fbf366bc712ae7a0938e245bb574fc045d03815f"; //sample signature r (second arrived)
    char pubx32[] = "ED44653F01F42FE33BEE8FF29E9A2BBDE0543CFBA8E716EC338DC527DEC1AEC5"; //pub key X
    char puby32[] = "A34C4D6E208DD45D2DC6ECE550349E1DEE98B3C2F8AAF6FC47C464A0BB2BCFF2"; //pub key Y

    if (verifySignature( digest32 , sigr32 , sigs32, pubx32, puby32) != 1) {
        printf("Failed to verify EC Signature\n");
    } else {
        printf("Verifed EC Signature\n");
    }
    return 0;
}
