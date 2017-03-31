function [ res ] = run_net( img, net_path, save_path )
%run_net - Run the network in net_path
%   img - Input Image
%   net_path - The network path
%   save_path - Path for saving the network's output

matname = [save_path '.mat'];
img = double(img);
save(matname, 'img');
resname = [save_path  '-res.mat'];
system(['OMP_NUM_THREADS=1 th run_net.lua -model ' net_path ' -inputs ' matname ...
    ' -res ' resname ]);
net_res = load(resname);
delete(matname);
delete(resname);
res = net_res.x;


end

