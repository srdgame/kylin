SHLIB_FLAGS	   = -shared
TPL_LDFLAGS    = -lluajit-5.1
TPL_CFLAGS     = -I/usr/include/luajit-2.0 -fPIC
TPL_SO         = parser.so
TPL_PO2LMO     = po2lmo
TPL_PO2LMO_OBJ = src/po2lmo.o
TPL_LMO_OBJ    = src/template_lmo.o
TPL_COMMON_OBJ = src/template_parser.o src/template_utils.o
TPL_LUALIB_OBJ = src/template_lualib.o

%.o: %.c
	$(CC) $(TPL_CFLAGS) $(LUA_CFLAGS) $(FPIC) -c -o $@ $<

all: $(TPL_COMMON_OBJ) $(TPL_LUALIB_OBJ) $(TPL_LMO_OBJ) $(TPL_PO2LMO_OBJ)
	$(CC) $(SHLIB_FLAGS) $(TPL_LDFLAGS) -o $(TPL_SO) \
		$(TPL_COMMON_OBJ) $(TPL_LMO_OBJ) $(TPL_LUALIB_OBJ)
	$(CC) -o $(TPL_PO2LMO) \
		$(TPL_LMO_OBJ) $(TPL_PO2LMO_OBJ) 

clean:
	rm -f src/*.o $(TPL_SO) $(TPL_PO2LMO)

