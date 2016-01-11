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
    T cx, cy, cz; // center of the grid (in real coordinate)
    T dx, dy, dz; // grid width
    int i, j, k;  // integer pos (in integer coordinate)

    Grid!T* next_x, prev_x;
    Grid!T* next_y, prev_y;
    Grid!T* next_z, prev_z;

    this(T x, T y, T z, T dx0, T dy0, T dz0)
    {
        cx = x; cy = y; cz = z;
        dx = dx0; dy = dy0; dz = dz0;
    }

    void setItr(int ti, int tj, int tk)
    {
        i = ti; j = tj; k = tk;
    }

    mixin gridPtrImpl!("x");
    mixin gridPtrImpl!("y");
    mixin gridPtrImpl!("z");
    mixin threeDBaseImpl!(T, "pos", cx, cy, cz);

    // Yee-latice
    // Efield
    T* ex_hxpypz;
    T* ex_hxpynz;
    T* ex_hxnypz;
    T* ex_hxnynz;
    T* ey_pxhypz;
    T* ey_pxhynz;
    T* ey_nxhypz;
    T* ey_nxhynz;
    T* ez_pxpyhz;
    T* ez_pxnyhz;
    T* ez_nxpyhz;
    T* ez_nxnyhz;

    // Bfield
    T* bx_pxhyhz;
    T* bx_nxhyhz;
    T* by_hxpyhz;
    T* by_hxnyhz;
    T* bz_hxhypz;
    T* bz_hxhynz;

    // rho
    T* rho_pxpypz;
    T* rho_pxpynz;
    T* rho_pxnypz;
    T* rho_pxnynz;
    T* rho_nxpypz;
    T* rho_nxpynz;
    T* rho_nxnypz;
    T* rho_nxnynz;
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
        static if(fname == "e")
        {
            x = new T[][][](nx, ny+1, nz+1);
            y = new T[][][](nx+1, ny, nz+1);
            z = new T[][][](nx+1, ny+1, nz);
            phi = new T[][][](nx+1, ny+1, nz+1);
            rho = new T[][][](nx+1, ny+1, nz+1);
        }else static if(fname =="b")
        {
            x = new T[][][](nx+1, ny, nz);
            y = new T[][][](nx, ny+1, nz);
            z = new T[][][](nx, ny, nz+1);
        }
    }
}

void grid_init(T)(ref Grid!T[] grids, int nx, int ny, int nz, T dx, T dy, T dz)
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
                grids[itr] = new Grid!T(dx * (cast(T)i + 0.5L), dy * (cast(T)j + 0.5L), dz * (cast(T)k + 0.5L), dx, dy, dz);
                grids[itr].set_nx(&grids[getGridNum(i+1, j ,k)]);
                grids[itr].set_px(&grids[getGridNum(i-1, j ,k)]);
                grids[itr].set_ny(&grids[getGridNum(i, j+1 ,k)]);
                grids[itr].set_py(&grids[getGridNum(i, j-1 ,k)]);
                grids[itr].set_nz(&grids[getGridNum(i, j ,k+1)]);
                grids[itr].set_pz(&grids[getGridNum(i, j ,k-1)]);
                grids[itr].setItr(i, j, k);
            }
        }
    }
}

void bindFieldToGrid(T)(FieldValue!(T, "e") ef, FieldValue!(T, "b") bf, ref Grid!T[] grids)
{
    foreach(Grid!T g; grids)
    {
        int i = g.i; int j = g.j; int k = g.k;
        // set ptr to efield
        g.ex_hxpypz = &(ef.x[i][j  ][k  ]);
        g.ex_hxpynz = &(ef.x[i][j  ][k+1]);
        g.ex_hxnypz = &(ef.x[i][j+1][k  ]);
        g.ex_hxnynz = &(ef.x[i][j+1][k+1]);

        g.ey_pxhypz = &(ef.y[i  ][j][k  ]);
        g.ey_pxhynz = &(ef.y[i  ][j][k+1]);
        g.ey_nxhypz = &(ef.y[i+1][j][k  ]);
        g.ey_nxhynz = &(ef.y[i+1][j][k+1]);

        g.ez_pxpyhz = &(ef.z[i  ][j  ][k]);
        g.ez_nxpyhz = &(ef.z[i+1][j  ][k]);
        g.ez_pxnyhz = &(ef.z[i  ][j+1][k]);
        g.ez_nxnyhz = &(ef.z[i+1][j+1][k]);

        // set ptr to bfield
        g.bx_pxhyhz = &(bf.x[i  ][j][k]);
        g.bx_nxhyhz = &(bf.x[i+1][j][k]);

        g.by_hxpyhz = &(bf.y[i][j  ][k]);
        g.by_hxnyhz = &(bf.y[i][j+1][k]);

        g.bz_hxhypz = &(bf.z[i][j][k  ]);
        g.bz_hxhynz = &(bf.z[i][j][k+1]);

        // set ptr to rho
        g.rho_pxpypz = &(ef.rho[i  ][j  ][k  ]);
        g.rho_pxpynz = &(ef.rho[i  ][j  ][k+1]);
        g.rho_pxnypz = &(ef.rho[i  ][j+1][k  ]);
        g.rho_pxnynz = &(ef.rho[i  ][j+1][k+1]);
        g.rho_nxpypz = &(ef.rho[i+1][j  ][k  ]);
        g.rho_nxpynz = &(ef.rho[i+1][j  ][k+1]);
        g.rho_nxnypz = &(ef.rho[i+1][j+1][k  ]);
        g.rho_nxnynz = &(ef.rho[i+1][j+1][k+1]);
    }
}
