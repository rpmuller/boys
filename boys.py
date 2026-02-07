def Fgamma(m,x):
    """
    Incomplete gamma function
    >>> np.isclose(Fgamma(0,0),1.0)
    True
    """
    SMALL=1e-12
    x = max(x,SMALL)
    return 0.5*pow(x,-m-0.5)*gamm_inc(m+0.5,x)

def gamm_inc(a,x):
    """
    Incomplete gamma function; computed from NumRec routine gammp.
    >>> np.isclose(gamm_inc(0.5,1),1.49365)
    True
    >>> np.isclose(gamm_inc(1.5,2),0.6545103)
    True
    >>> np.isclose(gamm_inc(2.5,1e-12),0)
    True
    """
    assert (x > 0 and a >= 0), "Invalid arguments in routine gamm_inc: %s,%s" % (x,a)

    if x < (a+1.0): #Use the series representation
        gam,gln = _gser(a,x)
    else: #Use continued fractions
        gamc,gln = _gcf(a,x)
        gam = 1-gamc
    return np.exp(gln)*gam

def _gser(a,x):
    "Series representation of Gamma. NumRec sect 6.1."
    ITMAX=100
    EPS=3.e-7

    gln=lgamma(a)
    assert(x>=0),'x < 0 in gser'
    if x == 0 : return 0,gln

    ap = a
    delt = sum = 1./a
    for i in range(ITMAX):
        ap=ap+1.
        delt=delt*x/ap
        sum=sum+delt
        if abs(delt) < abs(sum)*EPS: break
    else:
        logger.warning('a too large, ITMAX too small in gser')
    gamser=sum*np.exp(-x+a*np.log(x)-gln)
    return gamser,gln

def _gcf(a,x):
    "Continued fraction representation of Gamma. NumRec sect 6.1"
    ITMAX=100
    EPS=3.e-7
    FPMIN=1.e-30

    gln=lgamma(a)
    b=x+1.-a
    c=1./FPMIN
    d=1./b
    h=d
    for i in range(1,ITMAX+1):
        an=-i*(i-a)
        b=b+2.
        d=an*d+b
        if abs(d) < FPMIN: d=FPMIN
        c=b+an/c
        if abs(c) < FPMIN: c=FPMIN
        d=1./d
        delt=d*c
        h=h*delt
        if abs(delt-1.) < EPS: break
    else:
        logger.warning('a too large, ITMAX too small in gcf')
    gammcf=np.exp(-x+a*np.log(x)-gln)*h
    return gammcf,gln
