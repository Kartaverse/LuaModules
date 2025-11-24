local ffi = require("ffi")

-- Get the path of the current script to locate the shared library
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") or "./"
end

local lib_path = get_script_path() .. "stb_image.so"
local stb = ffi.load(lib_path)

ffi.cdef[[
    typedef unsigned char stbi_uc;
    typedef unsigned short stbi_us;

    typedef struct
    {
       int      (*read)  (void *user,char *data,int size);
       void     (*skip)  (void *user,int n);
       int      (*eof)   (void *user);
    } stbi_io_callbacks;

    stbi_uc *stbi_load_from_memory   (stbi_uc           const *buffer, int len   , int *x, int *y, int *channels_in_file, int desired_channels);
    stbi_uc *stbi_load_from_callbacks(stbi_io_callbacks const *clbk  , void *user, int *x, int *y, int *channels_in_file, int desired_channels);
    stbi_uc *stbi_load            (char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
    stbi_uc *stbi_load_from_file  (void *f, int *x, int *y, int *channels_in_file, int desired_channels);
    
    stbi_uc *stbi_load_gif_from_memory(stbi_uc const *buffer, int len, int **delays, int *x, int *y, int *z, int *comp, int req_comp);
    
    stbi_us *stbi_load_16_from_memory   (stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels);
    stbi_us *stbi_load_16_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels);
    stbi_us *stbi_load_16          (char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
    stbi_us *stbi_load_from_file_16(void *f, int *x, int *y, int *channels_in_file, int desired_channels);
    
    float *stbi_loadf_from_memory     (stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels);
    float *stbi_loadf_from_callbacks  (stbi_io_callbacks const *clbk, void *user, int *x, int *y,  int *channels_in_file, int desired_channels);
    float *stbi_loadf            (char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
    float *stbi_loadf_from_file  (void *f, int *x, int *y, int *channels_in_file, int desired_channels);
    
    void   stbi_hdr_to_ldr_gamma(float gamma);
    void   stbi_hdr_to_ldr_scale(float scale);
    void   stbi_ldr_to_hdr_gamma(float gamma);
    void   stbi_ldr_to_hdr_scale(float scale);
    
    int    stbi_is_hdr_from_callbacks(stbi_io_callbacks const *clbk, void *user);
    int    stbi_is_hdr_from_memory(stbi_uc const *buffer, int len);
    int      stbi_is_hdr          (char const *filename);
    int      stbi_is_hdr_from_file(void *f);
    
    const char *stbi_failure_reason  (void);
    void     stbi_image_free      (void *retval_from_stbi_load);
    
    int      stbi_info_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp);
    int      stbi_info_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *comp);
    int      stbi_is_16_bit_from_memory(stbi_uc const *buffer, int len);
    int      stbi_is_16_bit_from_callbacks(stbi_io_callbacks const *clbk, void *user);
    
    int      stbi_info               (char const *filename,     int *x, int *y, int *comp);
    int      stbi_info_from_file     (void *f,                  int *x, int *y, int *comp);
    int      stbi_is_16_bit          (char const *filename);
    int      stbi_is_16_bit_from_file(void *f);
    
    void stbi_set_unpremultiply_on_load(int flag_true_if_should_unpremultiply);
    void stbi_convert_iphone_png_to_rgb(int flag_true_if_should_convert);
    void stbi_set_flip_vertically_on_load(int flag_true_if_should_flip);
    
    void stbi_set_unpremultiply_on_load_thread(int flag_true_if_should_unpremultiply);
    void stbi_convert_iphone_png_to_rgb_thread(int flag_true_if_should_convert);
    void stbi_set_flip_vertically_on_load_thread(int flag_true_if_should_flip);
    
    char *stbi_zlib_decode_malloc_guesssize(const char *buffer, int len, int initial_size, int *outlen);
    char *stbi_zlib_decode_malloc_guesssize_headerflag(const char *buffer, int len, int initial_size, int *outlen, int parse_header);
    char *stbi_zlib_decode_malloc(const char *buffer, int len, int *outlen);
    int   stbi_zlib_decode_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);
    
    char *stbi_zlib_decode_noheader_malloc(const char *buffer, int len, int *outlen);
    int   stbi_zlib_decode_noheader_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);

    // Write functions
    int stbi_write_png(char const *filename, int w, int h, int comp, const void  *data, int stride_in_bytes);
    int stbi_write_bmp(char const *filename, int w, int h, int comp, const void  *data);
    int stbi_write_tga(char const *filename, int w, int h, int comp, const void  *data);
    int stbi_write_hdr(char const *filename, int w, int h, int comp, const float *data);
    int stbi_write_jpg(char const *filename, int x, int y, int comp, const void  *data, int quality);
    
    typedef void stbi_write_func(void *context, void *data, int size);

    int stbi_write_png_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data, int stride_in_bytes);
    int stbi_write_bmp_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
    int stbi_write_tga_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const void  *data);
    int stbi_write_hdr_to_func(stbi_write_func *func, void *context, int w, int h, int comp, const float *data);
    int stbi_write_jpg_to_func(stbi_write_func *func, void *context, int x, int y, int comp, const void  *data, int quality);

    void stbi_flip_vertically_on_write(int flip_boolean);
]]

return stb