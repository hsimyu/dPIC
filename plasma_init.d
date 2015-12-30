module plasma_init;
import physical_const;
import std.stdio;
import local_const;
import particle;
import std.random;
import std.math;

void init_plasma(acc)(Particle!(acc)[] par, ParticleType!(acc)[] ptype, int pnum)
{
    int max_ptype = 2;
    // define particle type
    ptype ~= new ParticleType!(acc)(Cme, Cqe, 0.0L, 10.0L, 1.0e6, "electron", 20);
    ptype ~= new ParticleType!(acc)(Cmi, -Cqe, 0.0L, 10.0L, 1.0e6, "proton", 20);
    foreach(int i; 0..max_ptype)
    {
        ptype[i].set_repnum(dx, dy, dz);
    }
    
    Mt19937[max_random_num] gen;
    foreach(int i; 0..max_random_num)
    {
        gen[i].seed(unpredictableSeed);
    }

    real r1, r2, r3, r4, r5, r6;
    auto gs = &gasdev!(Mt19937, acc);

    foreach(int i; 0..pnum)
    {
        r1 = uniform(0.0L, 1.0L, gen[0]) * lx;
        r2 = uniform(0.0L, 1.0L, gen[1]) * ly;
        r3 = uniform(0.0L, 1.0L, gen[2]) * lz;
        r4 = gs(3, gen[3]);
        r5 = gs(4, gen[4]);
        r6 = gs(5, gen[5]);

        par ~= new Particle!(acc)(r1, r2, r3, r4, r5, r6);
        par[i].pid = (i < pnum/2) ? 1 : 2;

        par[i].write_pos;
        par[i].write_vel;
        writeln;
    }
}

acc gasdev(GenClass, acc)(int ipar, ref GenClass gen)
{
    acc rsq, fac, v1, v2;
    static int[max_random_num] iset = 0;
    static acc[max_random_num] gset = 0.0;

    if(iset[ipar] == 0)
    {
        rsq = 0.0;
        while ((rsq >= 1.0) || (rsq == 0.0))
        {
            v1 = 2.0 * uniform(0.0L, 1.0L, gen) - 1.0;
            v2 = 2.0 * uniform(0.0L, 1.0L, gen) - 1.0;
            rsq = v1*v1 + v2*v2;
        }

        fac = sqrt((-2.0 * log(rsq)) / rsq);
        gset[ipar] = v1 * fac;
        iset[ipar] = 1;

        return v2 * fac;

    } else
    {
        iset[ipar] = 0;
        return gset[ipar];
    }
}
