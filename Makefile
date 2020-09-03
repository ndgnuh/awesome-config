LUAVER="lua5.3"
INCLUDE="-I/usr/include/$(LUAVER)/"
LIBOPTS="-shared"
FLAGS="-fpic"
CXX="gcc"

c_helper.so: lua-helper.c
	$(CXX)  $^ $(INCLUDE) $(FLAGS) $(LIBOPTS) -o $@

clean:
	rm c_helper.so
