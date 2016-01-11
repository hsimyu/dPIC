module particle;
import three_d_base;
import std.stdio;

class Particle(T){
    public:
        T x;
        T y;
        T z;
        T vx;
        T vy;
        T vz;
        ParticleType!(T)* ptype;

        this(){
            x = 0.0;
            y = 0.0;
            z = 0.0;
            vx = 0.0;
            vy = 0.0;
            vz = 0.0;
        }

        this(T x1, T y1, T z1, T vx1, T vy1, T vz1){
            x = x1;
            y = y1;
            z = z1;
            vx = vx1;
            vy = vy1;
            vz = vz1;
        }

        void setPosition(T x1, T y1, T z1){
            x = x1;
            y = y1;
            z = z1;
        }

        void setVelocity(T vx1, T vy1, T vz1){
            vx = vx1;
            vy = vy1;
            vz = vz1;
        }

        void updatePosition(){
            x = x + vx;
            y = y + vy;
            z = z + vz;
        }

        void setPtype(ParticleType!(T)* p){
            ptype = p;
        }

        mixin threeDBaseImpl!(T, "pos", x, y, z);
        mixin threeDBaseImpl!(T, "vel", vx, vy, vz);
}

class ParticleType(T)
{
    public:
        T mass;
        T charge;
        T radius;
        T temp;
        T dens;
        string name;
        int per_cell;
        int repnum;

        this(T m, T c, T r, T te, T de, string na, int pc)
        {
            mass = m;
            charge = c;
            radius = r;
            temp = te;
            dens = de;
            name = na;
            per_cell = pc;
        }

        void set_repnum(T dx, T dy, T dz)
        {
            // TODO: calc volume
            repnum = cast(int)( dx * dy * dz * dens / per_cell );
        }
}
