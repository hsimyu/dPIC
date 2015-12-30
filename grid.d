module grid;

class Grid(T)
{
    int number;
    
    T cx, cy, cz; // center of the grid
    T dx, dy, dz;

    this(T x, T y, T z, T dx0, T dy0, T dz0)
    {
        cx = x; cy = y; cz = z;
        dx = dx0; dy = dy0; dz = dz0;
    }

    mixin fieldImpl!(real, "e");
    mixin fieldImpl!(real, "b");
}

template fieldImpl(T, string fname)
{
    mixin("T pxv_" ~ fname ~ ";");
    mixin("T nxv_" ~ fname ~ ";");
    mixin("T pyv_" ~ fname ~ ";");
    mixin("T nyv_" ~ fname ~ ";");
    mixin("T pzv_" ~ fname ~ ";");
    mixin("T nzv_" ~ fname ~ ";");
}
