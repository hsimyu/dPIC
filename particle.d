module particle;
import std.stdio;

template threeDBaseImpl(T, string cname, alias x1, alias y1, alias z1){
    mixin(" void write_" ~ cname ~ "(){ writefln(\"%s:%s, %s, %s\", cname, x1, y1, z1); } ");
    mixin(" void write_" ~ cname ~ "E(){ writefln(\"%s:%.15e, %.15e, %.15e\", cname, x1, y1, z1); } ");
    mixin(" string get_type(){ return T.stringof; } ");
}

class Position(T){
    T x;
    T y;
    T z;

    this(T x0, T y0, T z0){
        x = x0;
        y = y0;
        z = z0;
    }

    Position opBinary(string op)(Position rhs){
        static if (op == "+") return new Position(this.x + rhs.x, this.y + rhs.y, this.z + rhs.z);
        else if (op == "-") return new Position(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z);
        else static assert(0, "Operator "~op~" not implemented.");
    }

    Position opBinary(string op)(T rhs){
        static if (op == "/") return new Position(this.x/rhs, this.y/rhs, this.z/rhs);
        else static assert(0, "Operator "~op~" not implemented.");
    }

    Position!(int) castToInt(){
        return new Position!(int)(cast(int)this.x, cast(int)this.y, cast(int)this.z);
    }

    mixin threeDBaseImpl!(double, "pos", x, y, z);
}

class Velocity(T){
    T vx;
    T vy;
    T vz;

    this(T vx1, T vy1, T vz1){
        vx = vx1;
        vy = vy1;
        vz = vz1;
    }

    Velocity opBinary(string op)(Velocity rhs){
        static if (op == "+") return new Velocity(this.vx + rhs.vx, this.y + rhs.vy, this.vz + rhs.vz);
        else if (op == "-") return new Velocity(this.vx - rhs.vx, this.vy - rhs.vy, this.vz - rhs.vz);
        else static assert(0, "Operator "~op~" not implemented.");
    }

    Velocity opBinary(string op)(T rhs){
        static if (op == "/") return new Velocity(this.vx/rhs, this.vy/rhs, this.vz/rhs);
        else static assert(0, "Operator "~op~" not implemented.");
    }

    mixin threeDBaseImpl!(double, "vel", vx, vy, vz);
}

class Particle(T){
    public:
        T x;
        T y;
        T z;
        T vx;
        T vy;
        T vz;
        int pid;

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

        this(Position!(T) pos, Velocity!(T) vel){
            x = pos.x;
            y = pos.y;
            z = pos.z;
            vx = vel.vx;
            vy = vel.vy;
            vz = vel.vz;
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

        mixin threeDBaseImpl!(double, "pos", x, y, z);
        mixin threeDBaseImpl!(double, "vel", vx, vy, vz);
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
