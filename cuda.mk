.cu.o:
	$(NVCC) -arch=sm_61 -std=c++17 --no-exceptions -O3 --default-stream per-thread -o $@ -c $<

.cu.lo:
	$(top_srcdir)/cudalt.py $@ $(NVCC) -arch=sm_61 -std=c++17 --no-exceptions -O3 --default-stream per-thread --compiler-options=\" $(CFLAGS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) \" -c $<

CUDA_LIBS = -lcu_ocb -lcudart
