#!/usr/local/bin/rdmd
import physical_const;
import plasma_init;
import std.stdio;
import local_const;
import particle;
import std.random;
import grid;

void main(){
    // define main accuracy
    alias acc = real;

    nx = 64; ny = 64; nz = 64;
    dx = 0.2; dy = 0.2; dz = 0.2;
    lx = dx * cast(acc)nx;
    ly = dy * cast(acc)ny;
    lz = dz * cast(acc)nz;
    int particle_num = 1000;

    Particle!(acc)[] par;
    ParticleType!(acc)[] ptype;
    Grid!(acc)[] grids;

    init_plasma!(acc)(par, ptype, particle_num);
}
