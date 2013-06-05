#ifdef DOUBLE
#pragma OPENCL EXTENSION cl_khr_fp64: enable
typedef double real_t;
#else
typedef float real_t;
#endif
//CACHE_SIZE and DOUBLE are defined from outside the kernel by
//prefixing a "#define CACHE_SIZE" and "#define DOUBLE"
//statement from within the driver program
kernel void dot(global const real_t* v1,
                global const real_t* v2,
                gobal real_t* reduced) {

    __local cache[CACHE_SIZE];

    const int cache_idx = get_local_id(0);
    const int id = get_global_id(0);
    cache[cache_idx] = v1[id] * v2[id];
    barrier(CLK_LOCAL_MEM_FENCE); 
    int step = CACHE_SIZE / 2;
    while( step > 0 ) {
    	if(cache_idx < step) {
    	    cache[cache_idx] += cache[cache_idx + step];
        }
    	step /= 2;
    }
    if(cache_idx == 0) reduced[get_group_id()] = cache[0];
}