module grid;
import three_d_base;
import std.stdio;

template gridPtrImpl(string str)
{
    mixin("void set_n" ~ str ~ "(Grid!T* g){ next_" ~ str ~ " = g; }");
    mixin("void set_p" ~ str ~ "(Grid!T* g){ prev_" ~ str ~ " = g; }");
}

class Grid(T)
{
    int number;
    
    T cx, cy, cz; // center of the grid
    T dx, dy, dz; // grid width

    Grid!T* next_x, prev_x;
    Grid!T* next_y, prev_y;
    Grid!T* next_z, prev_z;

    this(T x, T y, T z, T dx0, T dy0, T dz0)
    {
        cx = x; cy = y; cz = z;
        dx = dx0; dy = dy0; dz = dz0;
    }

    mixin gridPtrImpl!("x");
    mixin gridPtrImpl!("y");
    mixin gridPtrImpl!("z");
    mixin threeDBaseImpl!(T, "pos", cx, cy, cz);

    // Yee-latice
    // Efield
    // for x vector
    T hxpypz_ex;
    T hxpynz_ex;
    T hxnypz_ex;
    T hxnynz_ex;
    // for y vector
    T pxhypz_ey;
    T pxhynz_ey;
    T nxhypz_ey;
    T nxhynz_ey;
    // for z vector
    T pxpyhz_ez;
    T pxnyhz_ez;
    T nxpyhz_ez;
    T nxnyhz_ez;
    // Bfield
    // for x vector
    T pxhyhz_bx;
    T nxhyhz_bx;
    // for y vector
    T hxpyhz_by;
    T hxnyhz_by;
    // for z vector
    T hxhypz_bz;
    T hxhynz_bz;
}

class FieldValue(T, string fname)
{
    static if(fname == "e")
    {
        // phi on full grid
        mixin(" T[][][] phi; ");
        mixin(" T[][][] rho; ");
    }

    // efield on half grid
    mixin(" T[][][] "~fname~"x;");
    mixin(" T[][][] "~fname~"y;");
    mixin(" T[][][] "~fname~"z;");

    mixin(" alias x = " ~ fname ~ "x; ");
    mixin(" alias y = " ~ fname ~ "y; ");
    mixin(" alias z = " ~ fname ~ "z; ");

    this(int nx, int ny, int nz)
    {
        x = new T[][][](nx-1, ny, nz);
        y = new T[][][](nx, ny-1, nz);
        z = new T[][][](nx, ny, nz-1);

        init_3d_array(x);
        init_3d_array(y);
        init_3d_array(z);

        static if(fname == "e")
        {
            phi = new T[][][](nx, ny, nz);
            rho = new T[][][](nx, ny, nz);
            init_3d_array(phi);
            init_3d_array(rho);
        }
    }
}

void init_3d_array(T)(ref T[][][] x){
    foreach(ref x1; x)
    {
        foreach(ref x2; x1)
        {
            foreach(ref x3; x2)
            {
                x3 = 0.0L;
            }
        }
    }
}

void grid_init(T)(Grid!T[] grids, int nx, int ny, int nz, T dx, T dy, T dz)
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

    grids.length = nx*ny*nz;
    foreach(int i; 0..nx)
    {
        foreach(int j; 0..ny)
        {
            foreach(int k; 0..nz)
            {
                int itr = k + j * nz + i * ny * nz;
                grids[itr] = new Grid!T(cast(T)i + 0.5L, cast(T)j + 0.5L, cast(T)k + 0.5L, dx, dy, dz);
                grids[itr].set_nx(&grids[getGridNum(i+1, j ,k)]);
                grids[itr].set_px(&grids[getGridNum(i-1, j ,k)]);
                grids[itr].set_ny(&grids[getGridNum(i, j+1 ,k)]);
                grids[itr].set_py(&grids[getGridNum(i, j-1 ,k)]);
                grids[itr].set_nz(&grids[getGridNum(i, j ,k+1)]);
                grids[itr].set_pz(&grids[getGridNum(i, j ,k-1)]);
            }
        }
    }
}
