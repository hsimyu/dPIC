module three_d_base;
import std.stdio;

template threeDBaseImpl(T, string cname, alias x1, alias y1, alias z1){
    mixin(" void write_" ~ cname ~ "(){ writefln(\"%s:%s, %s, %s\", cname, x1, y1, z1); } ");
    mixin(" void write_" ~ cname ~ "E(){ writefln(\"%s:%.15e, %.15e, %.15e\", cname, x1, y1, z1); } ");
    mixin(" string get_type(){ return T.stringof; } ");
}

