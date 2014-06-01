rn = 0;
fl = 0;
cl = 0;
ct = 0;
vl = 1.1;
mx = 0;
mr = 0;
rm = 0;
mc = 0;
cm = 0;
for i = 1 : 5000000
    vl = vl * 1.0001;
    mx = max(vl, 1);
    rn = round(vl);
    fl = floor(vl);
    cl = ceil(vl);
    ct = uint32(vl);
    
    mr = max(round(vl), 1);
    rm = round(max(vl, 1));

    mc = max(uint32(vl), 1);
    cm = uint32(max(vl, 1));
end