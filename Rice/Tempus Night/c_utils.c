#include <lua.h>
#include <stdio.h>
#include <lauxlib.h>
#include <lualib.h>

static void stackDump (lua_State *L) {
	int i;
	int top = lua_gettop(L);
	for (i = 1; i <= top; i++) {  /* repeat for each level */
		int t = lua_type(L, i);
		switch (t) {

			case LUA_TSTRING:  /* strings */
				printf("`%s'", lua_tostring(L, i));
				break;

			case LUA_TBOOLEAN:  /* booleans */
				printf(lua_toboolean(L, i) ? "true" : "false");
				break;

			case LUA_TNUMBER:  /* numbers */
				printf("%g", lua_tonumber(L, i));
				break;

			default:  /* other values */
				printf("%s", lua_typename(L, t));
				break;

		}
		printf("  ");  /* put a separator */
	}
	printf("\n");  /* end the listing */
}

int l_map (lua_State *L) {
	int i, n;

	/* 1st argument must be a function (f) */
	luaL_checktype(L, 1, LUA_TFUNCTION);

	/* 2nd argument must be a table (t) */
	luaL_checktype(L, 2, LUA_TTABLE);

	n = luaL_len(L, 2);  /* get size of table */

	/* return another table (t2) */
	lua_createtable(L, n, 0);

	for (i=1; i<=n; i++) {
		lua_pushvalue(L, 1);   /* push f */
		lua_rawgeti(L, 2, i);  /* push t[i] */
		lua_call(L, 1, 1);     /* call f(t[i]) */
		lua_rawseti(L, 3, i);  /* t2[i] = result */
	}

	return 1;  /* return new table */
}

int l_vmap(lua_State *L) {
	int i;
	int n = lua_gettop(L); /* number of args */

	luaL_checktype(L, 1, LUA_TFUNCTION); /* first args function */

	/* n for the input
	 * 2 for the function and function input
	 */
	lua_checkstack(L, n + 2);

	for(i = 2; i <= n; i++) {
		lua_pushvalue(L, 1);
		lua_pushvalue(L, i);
		lua_call(L, 1, 1);
		/* replace the old value */
		lua_remove(L, i);
		lua_insert(L, i);
	}

	return n - 1; /* everything except the function */
}

int l_mapinplace(lua_State *L) {
	int i, n;
	/* 1st argument must be a function (f) */
	luaL_checktype(L, 1, LUA_TFUNCTION);

	/* 2nd argument must be a table (t) */
	luaL_checktype(L, 2, LUA_TTABLE);

	n = luaL_len(L, 2);  /* get size of table */

	for (i=1; i<=n; i++) {
		lua_pushvalue(L, 1);   /* push f */
		lua_rawgeti(L, 2, i);  /* push t[i] */
		lua_call(L, 1, 1);     /* call f(t[i]) */
		lua_rawseti(L, 2, i);  /* t[i] = result */
	}

	return 1;  /* return table, for convenience */
}

int l_cycle(lua_State *L) {
	int n;
	int i;

	/* cycle(t::Table, i::Int) */
	luaL_checktype(L, 1, LUA_TTABLE);
	n = luaL_len(L, 1); /* table size */

	i = luaL_checkinteger(L, 2) + 1; /* next index */
	i = i > n ? 1 : i;

	lua_settop(L, 1);
	lua_pushinteger(L, i);

	return 1;
}

int l_foldl(lua_State *L) {
	int i, n;

	/* foldl(f::Function, t::Table) */
	luaL_checktype(L, 1, LUA_TFUNCTION);
	luaL_checktype(L, 2, LUA_TTABLE);

	n = luaL_len(L, 2); /* table size */

	/* if the table have less than 2 elements return nil */
	if (n < 2) {
		lua_pushnil(L);
		return 1;
	}

	lua_pushvalue(L, 1); /* push f [f, t, f] */
	lua_rawgeti(L, 2, 1); /* push t[1]: [f, t, f, v] */

	for(i = 2; i < n; i++) {
		lua_rawgeti(L, 2, i); /* push t[i]: [f, t, f, v, v] */
		lua_call(L, 2, 1); /* result: [f, t, v] */
		lua_pushvalue(L, 1); /* push f [f, t, v, f] */
		lua_insert(L, -2); /* swap(f, v): [f, t, f, v] */
	}

	// the last iteration
	// so no need to push f and swap this time
	lua_rawgeti(L, 2, n);
	lua_call(L, 2, 1);

	return 1;
}

/* range(start = 1, step = 1, stop?) */
int l_range(lua_State *L){
	int nargs, len, i, isint = 1;
	double start = 1, stop, step = 1;

	nargs = lua_gettop(L);

	for(i = 1; i <= nargs; i++) {
		luaL_checktype(L, i, LUA_TNUMBER);
		isint &= lua_isinteger(L, i);
	}

	switch(nargs) {
		case 0:
			return luaL_error(L, "invalid number of arguments, at least tell lua when to stop");
			break;
		case 1:
			stop = luaL_checknumber(L, 1);
			break;
		case 2:
			start = luaL_checknumber(L, 1);
			stop = luaL_checknumber(L, 2);
			break;
		default:
			start = luaL_checknumber(L, 1);
			step = luaL_checknumber(L, 2);
			stop = luaL_checknumber(L, 3);
			break;
	}

	// check if the range is valid
	if (stop < start) {
		return luaL_error(L, "invalid start/stop");
	}
	if (step == 0) {
		return luaL_error(L, "invalid step (step != 0)");
	}

	len = (stop - start) / step + 1;

	lua_createtable(L, len, 0);

	nargs = nargs + 1;
	for (i = 0; i < len; i++) {
		if (isint)
			lua_pushinteger(L, start + step * i);
		else
			lua_pushnumber(L, start + step * i);
		lua_rawseti(L, nargs, i + 1);
	}

	return 1;
}

static const struct luaL_Reg utillib[] = {
	{"map", l_map},
	{"vmap", l_vmap},
	{"mapinplace", l_mapinplace},
	{"cycle", l_cycle},
	{"foldl", l_foldl},
	{"range", l_range},
	{NULL, NULL}
};

int luaopen_c_utils(lua_State *L) {
	luaL_newlib(L, utillib);
	return 1;
}
