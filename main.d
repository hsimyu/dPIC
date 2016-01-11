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

    // nx, ny, nz : number of cells
    // NOTE: there are n+1 grid points in one direction
    nx = 10; ny = 10; nz = 10;
    dx = 0.2; dy = 0.2; dz = 0.2;
    lx = dx * cast(acc) nx;
    ly = dy * cast(acc) ny;
    lz = dz * cast(acc) nz;
    int particle_num = 1000;

    Particle!(acc)[] par;
    ParticleType!(acc)[] ptype;
    Grid!(acc)[] grids;
    FieldValue!(acc, "e") efield = new FieldValue!(acc, "e")(nx, ny, nz);
    FieldValue!(acc, "b") bfield = new FieldValue!(acc, "b")(nx, ny, nz);

    p_init!(acc)(par, ptype, particle_num);
    grid_init!acc(grids, nx, ny, nz, dx, dy, dz);
    bindFieldToGrid!acc(efield, bfield, grids);
    bindParticleToGrid!acc(par, grids);
}

void bindParticleToGrid(T)(ref Particle!T[] par, ref Grid!T[] grids)
{
    int getGridNum(int i, int j, int k)
    {
        // cyclic ptr
        i = (i < 0) ? nx - 1 : i;
        j = (j < 0) ? ny - 1 : j;
        k = (k < 0) ? nz - 1 : k;

        i = (i == nx) ? 0 : i;
        j = (j == ny) ? 0 : j;
        k = (k == nz) ? 0 : k;
        return k + j * nz + i * ny * nz;
    }

    foreach(Particle!T p; par)
    {
        int i = cast(int) (p.x/dx) ;
        int j = cast(int) (p.y/dy) ;
        int k = cast(int) (p.z/dz) ;

        p.setGrid(&grids[getGridNum(i, j, k)]);
    }
}
