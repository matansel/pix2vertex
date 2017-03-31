require 'nn'
require 'nngraph'
require 'mattorch'


function parse_args()
	cmd = torch.CmdLine()
	cmd:text('Options')
	-- general options:
	cmd:option('-model', '', 'Model Path')
	cmd:option('-inputs', '', 'Images Path')
    cmd:option('-res', '', 'Res Path')
	cmd:text()
	params = cmd:parse(arg)
	return params
end

params = parse_args()


model = torch.load(params.model)
input = mattorch.load(params.inputs)
in_im = input.img
in_im = in_im:view(1,in_im:size(1),in_im:size(2),in_im:size(3))
in_im = in_im:permute(1,2,4,3)
in_im:div(255.0):mul(2):add(-1) --Input Normalization
output = model:forward(in_im:double())
output:add(1):div(2):mul(255) --Output Denormalization
output = output:permute(1,2,4,3)
mattorch.save(params.res, output:double())
