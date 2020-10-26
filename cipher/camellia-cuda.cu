#define CAMELLIA_BLOCK_SIZE 16
#define CAMELLIA_TABLE_BYTE_LEN 272
#define CAMELLIA_TABLE_WORD_LEN (CAMELLIA_TABLE_BYTE_LEN / 4)

typedef unsigned int u64;

typedef unsigned int KEY_TABLE_TYPE[CAMELLIA_TABLE_WORD_LEN];

typedef struct {
  KEY_TABLE_TYPE keytable;
  int keybitlength;
#ifdef USE_AESNI_AVX
  unsigned int
      use_aesni_avx : 1; /* AES-NI/AVX implementation shall be used.  */
#endif                   /*USE_AESNI_AVX*/
#ifdef USE_AESNI_AVX2
  unsigned int
      use_aesni_avx2 : 1; /* AES-NI/AVX2 implementation shall be used.  */
#endif                    /*USE_AESNI_AVX2*/
} CAMELLIA_context;

extern "C" {
void _gcry_camellia_cuda_ocb_enc(CAMELLIA_context* ctx,
                                 unsigned char* out,
                                 const unsigned char* in,
                                 unsigned char* offset,
                                 unsigned char* checksum,
                                 const u64 Ls[32]);

void _gcry_camellia_cuda_ocb_dec(CAMELLIA_context* ctx,
                                 unsigned char* out,
                                 const unsigned char* in,
                                 unsigned char* offset,
                                 unsigned char* checksum,
                                 const u64 Ls[32]);
}

__global__ void VecAdd(float* A, float* B, float* C) {
  int i = threadIdx.x;
  C[i] = A[i] + B[i];
}

void _gcry_camellia_cuda_ocb_enc(CAMELLIA_context* ctx,
                                 unsigned char* out,
                                 const unsigned char* in,
                                 unsigned char* offset,
                                 unsigned char* checksum,
                                 const u64 Ls[32]) {}

void _gcry_camellia_cuda_ocb_dec(CAMELLIA_context* ctx,
                                 unsigned char* out,
                                 const unsigned char* in,
                                 unsigned char* offset,
                                 unsigned char* checksum,
                                 const u64 Ls[32]) {}
