#include <cu_ocb/ocb_camellia.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CAMELLIA_BLOCK_SIZE 16
#define CAMELLIA_TABLE_BYTE_LEN 272
#define CAMELLIA_TABLE_WORD_LEN (CAMELLIA_TABLE_BYTE_LEN / 4)

typedef unsigned int KEY_TABLE_TYPE[CAMELLIA_TABLE_WORD_LEN];

typedef struct
{
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

extern "C"
{
  uint64_t _gcry_camellia_cuda_ocb_encrypt(
      CAMELLIA_context* ctx, unsigned char* out, const unsigned char* in,
      unsigned char* offset0, unsigned char* checksum, uint64_t pos,
      uint64_t num_blocks, const unsigned char* L, int encrypt,
      float* time_enc, float* time_offset, float* time_checksum);
}

cu_ocb::OcbConfig makeConfig()
{
  cu_ocb::OcbConfig config{};
  if (const char* val = getenv("CUOCB_CPU_ENC"))
    config.camellia_on_gpu = false;
  else
    {
      if (const char* val = getenv("CUOCB_ENC_THREADS"))
        if (int v = atoi(val)) config.encrypt_threads = v;
      fprintf(stderr, "CUOCB_ENC_THREADS %d\n", config.encrypt_threads);
    }

  if (!config.camellia_on_gpu || getenv("CUOCB_CPU_OFFSET"))
    config.offset_mode = cu_ocb::OffsetComputation::ApplyOnCpu;
  else
    {
      if (const char* val = getenv("CUOCB_OFFSET_THREADS"))
        if (int v = atoi(val)) config.offset_threads = v;
      fprintf(stderr, "CUOCB_OFFSET_THREADS %d\n", config.offset_threads);
    }

  if (config.offset_mode == cu_ocb::OffsetComputation::ApplyOnCpu ||
      getenv("CUOCB_CPU_CHKSUM"))
    config.checksum_on_gpu = false;
  else
    {
      if (const char* val = getenv("CUOCB_CHKSUM_THREADS"))
        if (int v = atoi(val)) config.checksum_threads = v;
      fprintf(stderr, "CUOCB_CHKSUM_THREADS %d\n", config.checksum_threads);
    }

  // config.measure_gpu_time = false;
  // config.offset_mode = cu_ocb::OffsetComputation::ComputeOnCpu;
  // config.debug = true;
  // config.verify_with_cpu_result = true;
  // config.minimum_blocks = 32;
  // config.process_incomplete_block = false;
  return config;
}

uint64_t _gcry_camellia_cuda_ocb_encrypt(
    CAMELLIA_context* ctx, unsigned char* out, const unsigned char* in,
    unsigned char* offset, unsigned char* checksum, uint64_t pos,
    uint64_t num_blocks, const unsigned char* L, int encrypt, float* time_enc,
    float* time_offset, float* time_checksum)
{
  static auto config = makeConfig();
  static auto measure_gpu_time = config.measure_gpu_time;
  // return 0;
  static cu_ocb::OcbCamellia enc{std::move(config)};
  enc.setKeytable(ctx->keytable);

  constexpr size_t block_size = 16;
  constexpr size_t l_size = 34;
  auto result =
      enc.encrypt({reinterpret_cast<const char*>(in), num_blocks * block_size},
                  pos, {reinterpret_cast<const char*>(L), l_size * block_size},
                  *reinterpret_cast<__uint128_t*>(checksum),
                  *reinterpret_cast<__uint128_t*>(offset), out, encrypt);
  if (measure_gpu_time)
    {
      *time_enc += enc.gpuTimeSpent()->encryption_;
      *time_offset += enc.gpuTimeSpent()->ocb_offset_;
      *time_checksum += enc.gpuTimeSpent()->checksum_;
      // fprintf(stderr, "enc: %f -> %f\n", enc.gpuTimeSpent()->encryption_, *time_enc);
      // fprintf(stderr, "off: %f -> %f\n", enc.gpuTimeSpent()->ocb_offset_, *time_offset);
      // fprintf(stderr, "chk: %f -> %f\n", enc.gpuTimeSpent()->checksum_, *time_checksum);
    }
  return result;
}
