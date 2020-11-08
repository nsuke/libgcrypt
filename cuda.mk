.cu.o:
	$(NVCC) -std=c++17 --no-exceptions -o $@ -c $<

.cu.lo:
	$(top_srcdir)/cudalt.py $@ $(NVCC) -std=c++17 --no-exceptions --compiler-options=\" $(CFLAGS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) \" -c $<
