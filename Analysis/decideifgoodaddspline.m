function cells=decideifgoodaddspline(cells,pictimes,minlength,mincyto,splineparam,devthresh,useframes)
%cells=decideifgoodaddsplines(cells,pictimes,minlength,splineparam,devthresh)
%-------------------------------------------------------------------
%function to identify good trajectories and add smoothing splines
% good trajectories are those of sufficient length with fluor data missing
% that don't devaite too much from the smoothing spline.
%cells - cells structure with data
%pictimes - array with times each data point acquired
%minlength -- minimum length of good trajectory
%spline param -- param for smoothing spline (from 0 to 1, 0 -- line, 1 fit
%perfectly). Recommended ~0.95.
%dev thresh -- maximum fractional deviation between smoothing spline and
%               data to be considered good
%useframes--optional argument to restrict frames used for spline fitting

if ~exist('useframes','var') || isempty(useframes)
    useframes=1:length(pictimes);
    disp('For cells2: using all frames');
end

for cellnum=1:length(cells)
    of=cells(cellnum).onframes;
    uf=of(ismember(of,useframes));
    cells(cellnum).onframes=uf;
    cells(cellnum).data=cells(cellnum).data(ismember(of,useframes),:);
    nframes=length(cells(cellnum).onframes);
    goodframes=find(cells(cellnum).data(:,7)>0);
    ngoodframes=length(goodframes);
    
    if nframes < minlength || ngoodframes/nframes < mincyto
        cells(cellnum).good=0;
    else
        cells=addsplinestocell(cells,pictimes,goodframes,cellnum,splineparam);
        sppoints=cells(cellnum).data(:,8:10);
        datpoints=cells(cellnum).data(:,5:7);
        inds=datpoints > 0;
        dev=mean2(abs(sppoints(inds)-datpoints(inds))./datpoints(inds));
        if dev < devthresh
            cells(cellnum).good=1;
        else
            cells(cellnum).good=0;
        end
    end
end

function cells=addsplinestocell(cells,pictimes,goodframes,ii,sp)
%add smoothing spline to a cell in the cells array
xx=pictimes(cells(ii).onframes);
for yv=5:7
    yy=cells(ii).data(:,yv);
    pp=csaps(xx(goodframes),yy(goodframes),sp);
    cells(ii).data(:,yv+3)=fnval(pp,xx);
    cells(ii).splines(yv-4)=pp;
end
