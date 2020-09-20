LUAVER="lua5.3"
INCLUDE="-I/usr/include/$(LUAVER)/"
LIBOPTS="-shared"
FLAGS="-fpic"
CXX="gcc"

c_utils.so: c_utils.c
	$(CXX)  $^ $(INCLUDE) $(FLAGS) $(LIBOPTS) -o $@

clean:
	rm c_utils.so
