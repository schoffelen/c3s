function c3s_execute_script(scriptname, varargin)

% c3s_execute_script serves the purpose to make a script executable by qsub.
% supply it with the name of the script that has to be run, and the
% additional parameters required for the script to run
%
% example use (standalone; not so useful):
%
% mous_execute_pipeline('mous_bfica_pipeline', 'V001');



if numel(varargin)>0
  for k = 1:numel(varargin)
    eval([varargin{k}{1},'=varargin{k}{2}']);
  end
end
eval(scriptname);
