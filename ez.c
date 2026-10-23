/*
 * C extensions for Lua utilities
 * This module is named `ez`
 */ 
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <string.h>
#include <dirent.h>
#include <errno.h>

#include <stdio.h>
#include <stdlib.h>

static int l_nameof(lua_State *L) {
    lua_Debug ar;
    // 1. Get stack level 1 (the caller of ez.ic)
    if (lua_getstack(L, 1, &ar)) {
        // 2. Get Source ("S") and current line ("l")
        lua_getinfo(L, "Sl", &ar);

        // 'source' starts with '@' if it's a file path
        if (ar.source != NULL && ar.source[0] == '@') {
            const char *filename = ar.source + 1; // Skip the '@'
            FILE *f = fopen(filename, "r");
            if (f) {
                char line_buf[1024];
                int current = 0;
                // 3. Skip to the correct line
                while (fgets(line_buf, sizeof(line_buf), f)) {
                    if (++current == ar.currentline) {
                        // 4. Rudimentary parse: find "ez.ic(" and the closing ")"
                        char *start = strstr(line_buf, "ez.ic(");
                        if (start) {
                            start += 10; // Move past "ez.ic("
                            char *end = strrchr(start, ')');
                            if (end) {
                                *end = '\0'; // Terminate string at ')'
                                lua_pushstring(L, start);
                                fclose(f);
                                return 1;
                            }
                        }
                    }
                }
                fclose(f);
            }
        }
    }
    
    lua_pushstring(L, "unknown expression");
    return 1;
}

static int l_icecream(lua_State *L) {
    int n = lua_gettop(L);  /* number of arguments */

    lua_Debug ar;
    lua_getstack(L, 1, &ar);
    lua_getinfo(L, "lfSn", &ar);

    if (n == 1) {
        int i = 1;
        char* name = lua_getlocal(L, &ar, i++);
        while (name != NULL) {
            if (lua_compare(L, 1, -1, LUA_OPEQ)) {
                // Get file and function definition line info
                lua_getinfo(L, "S", &ar);

                printf("Variable name: %s\n", name);
                printf("Defined in file: %s\n", ar.short_src);
                printf("Function starts at line: %d\n", ar.linedefined);

                lua_pop(L, 1); // pop the value returned by lua_getlocal
                return 0;
            }
            lua_pop(L, 1);
        }
    }

    printf("\n=================\n");
    printf("Source short: %s\n", ar.short_src);
    printf("name: %s\n", ar.name);
    printf("namewhat: %s\n", ar.namewhat);
    printf("what: %s\n", ar.what);
    printf("source: %s\n", ar.source);
    printf("currentline: %d\n", ar.currentline);
    printf("linedefined: %d\n", ar.linedefined);
    printf("lastlinedefined: %d\n", ar.lastlinedefined);
    printf("nups: %d\n", ar.nups);
    printf("nparams: %d\n", ar.nparams);

    lua_pushstring(L, ar.name);
    lua_pushinteger(L, ar.istailcall);
    return 2;
}

/* apply(x, f) */
static int l_apply(lua_State *L) {
    /* check that first argument is a function */
    luaL_checktype(L, 2, LUA_TFUNCTION);

    /* check that second argument is a table */
    luaL_checktype(L, 1, LUA_TTABLE);     

    /* push the function */
    lua_pushvalue(L, 2);  

    /* push the table */
    lua_pushvalue(L, 1);  

    /* call the function with 1 argument and 1 result */
    lua_call(L, 1, 1);    

    return 1;  /* return the result */
}

static int l_range(lua_State *L) {
    int n = lua_gettop(L);
    int a, b, step;
    switch (n) {
        case 1:
            b = luaL_checkinteger(L, 1);
            a = 1;
            step = 1;
            break;
        case 2:
            a = luaL_checkinteger(L, 1);
            b = luaL_checkinteger(L, 2);
            step = 1;
            break;
        case 3:
            a = luaL_checkinteger(L, 1);
            b = luaL_checkinteger(L, 2);
            step = luaL_checkinteger(L, 3);
            if (step == 0) {
                return luaL_error(L, "step must not be zero");
            }
            break;
        default:
            return luaL_error(L, "range(a, b, step=1)", n);
    }

    // table: -1
    lua_newtable(L);
    int idx = 1;
    for (int i = a; i <= b; i += step) {
        lua_pushinteger(L, i);
        lua_rawseti(L, -2, idx++);
    }

    return 1;
}

/*
 * Map function that takes a table,
 * a lua function and returns mapped table
 * ez.map(tbl, function(item, index) ... end)
 */
static int l_map(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE); /* [table] */
    luaL_checktype(L, 2, LUA_TFUNCTION); /* [function] */
    lua_newtable(L); /* [tbl, fn, result] */
    lua_pushnil(L); /* [tbl, fn, result, nil] */
    int has_next = lua_next(L, 1); /* [tbl, fn, result, key, old] */
    while (has_next) {
        lua_pushvalue(L, 2); /* [tbl, fn, result, key, old, fn] */
        lua_insert(L, -2); /* [tbl, fn, result, key, fn, old] */
        lua_pushvalue(L, -3); /* [tbl, fn, result, key, fn, old, key] */
        lua_call(L, 2, 1); /* [tbl, fn, result, key, new] */
        lua_pushvalue(L, -2); /* [tbl, fn, result, key, new, key] */
        lua_insert(L, -2); /* [tbl, fn, result, key, key, new] */
        lua_settable(L, 3); /* [tbl, fn, result, key] */
        has_next = lua_next(L, 1) /* [tbl, fn, result, key, old] */;
    }
    /* After the loop: [fn, tbl, result] */
    lua_insert(L, 1); /* [result, fn, tbl] */
    lua_pop(L, 2); /* [result] */
    return 1;  /* return the first table */
}


static int l_dir (lua_State *L) {
    DIR *dir;
    struct dirent *entry;
    int i;
    const char *path = luaL_checkstring(L, 1);

    /* open directory */
    dir = opendir(path);
    if (dir == NULL) {  /* error opening the directory? */
        lua_pushnil(L);  /* return nil and ... */
        lua_pushstring(L, strerror(errno));  /* error message */
        return 2;  /* number of results */
    }

    /* create result table */
    lua_newtable(L);
    i = 1;
    while ((entry = readdir(dir)) != NULL) {
        lua_pushnumber(L, i++);  /* push key */
        lua_pushstring(L, entry->d_name);  /* push value */
        lua_settable(L, -3);
    }

    closedir(dir);
    return 1;  /* table is already on top */
}

static const struct luaL_Reg ezlib [] = {
    {"ls", l_dir},
    {"apply", l_apply},
    {"range", l_range},
    {"map", l_map},
    {"ic", l_icecream},
    {"nameof", l_nameof},
    {NULL, NULL}  /* sentinel */
};

int luaopen_ez(lua_State *L) {
    luaL_newlib(L, ezlib);
    return 1;
}
