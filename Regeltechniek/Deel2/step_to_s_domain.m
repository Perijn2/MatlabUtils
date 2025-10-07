function H_EST = step_to_s_domain(MatchModel)
%% 
% H_EST = step_to_s_domain('<MatchModel>')
%
% define the <MatchModel> to match with
% Pn for n poles, Zn for n zeros, 
% U for allowing complex poles
% D for allowing delay
% I for allowing an ideal integrator
%
% Examples:
% POID for 0 poles, 1 ideal integrator and 1 delay,
% P3Z  for 3 poles and 1 zero 
% P2Z  for 2 poles and 1 zero (handy for PD controllers)
% P3   for 3 poles
% POIZ for o poles, 1 ideal integrator and  zero (handy for PI controllers)
% etc
%
% The function will ask you to select a .csv file with stepresponse data
% and find an 's' model that fits your stepresponse.

%% Select file
% Have user browse for a file, from a specified "starting folder."
% For convenience in browsing, set a starting folder from which to browse.
StartingFolder = 'C:\Users\Perij\Documents\Matlab code';
if ~exist(StartingFolder, 'dir')
	% If that folder doesn't exist, just start in the current folder.
	StartingFolder = pwd;
end
% Get the name of the stepresponse data file that the user wants to use.
DefaultFileName = fullfile(StartingFolder, '*.*');
[BaseFileName, Folder] = uigetfile(DefaultFileName, 'Select a file');
if BaseFileName == 0
	% User clicked the Cancel button.
	return;
end
FullFileName = fullfile(Folder, BaseFileName);
clear StartingFolder DefaultFileName Folder;


%% load the stepresponse data as measured with for example  with a TiePie scope
load(FullFileName, '-ascii');
[dir,BaseFileName,ext]=fileparts(FullFileName);
stepdata = eval(BaseFileName)
y=stepdata(:,2);
t=stepdata(:,1);
%clear dir ext FullFileName stepdata;

%% Derive sample time from loaded response
N=length(t);
Tsmax=max(t(2:N)-t(1:N-1));
Tsmin=min(t(2:N)-t(1:N-1));
Ts=Tsmax;  
%% Process array with time values

% Find trigger point where time changes from negative to positive
if isempty(find(t==0,1))
    if isempty(find(t<0,1,'last'))
        Ntrig=find(t>0,1,'first');  % return one element from the start
    else
        Ntrig=find(t<0,1,'last');   % return one element from the end
    end
else
    Ntrig=find(t==0);
end

% start timing at zero
Tmin=min(t);
t=t-Tmin;

%% Create input signal
% The inputsignal of this response was
x=ones(N,1);
x(1:Ntrig)=0;

%% Prepend in case of step a number zero values to the dataarrays
% This is needed for the function 'pem' to operate better

% Define the number of samples to be prependend
Order=0;
% Only take action if the triggerpoint Ntrig is to close to the begin
% of the array
if Ntrig < 10
    Order = 10 - Ntrig;
end

clear y_pre x_pre t_pre;
if Order == 0 
 y_pre=y;
 x_pre=x;
 t_pre=t;
else
 y_pre(1:Order)=y(1);
 y_pre(Order+1:Order+N)=y.';
 y_pre=y_pre.';
 x_pre(1:Order)=x(1);
 x_pre(Order+1:Order+N)=x.';
 x_pre=x_pre.';
 t_pre=t(1):Ts:t(1)+(N-1+Order)*Ts;
 t_pre=t_pre.';
end
% Correct the number of samples
N=N+Order;

%% create an iddata model
stepdata = iddata(y_pre,x_pre,Ts);
%give columns in iddata object a name
set(stepdata,'InputName','BlackBox Input','OutputName','BlackBox Out');
set(stepdata,'InputUnit','Volt','OutputUnit','Volt');
h=figure(101); set(h,'WindowStyle','docked');
clf; %clear figure in case figure(101) has been used in an other simulation
plot(stepdata);
grid on;
xlabel('Time (s)');


%% define a model using idproc 
m_est=idproc(MatchModel);
model=pem(stepdata,m_est);
H_EST = zpk(model);
% Possibilities for reading values from the model are as follows:
% Outputdelay=model.Td.value;
% Pole1_est=1/model.Tp1.value;
% Gain_est=model.Kp.value*-Pole1_est*-Pole2_est*-Pole3_est;
% determine if there is a zero
% zero_est=m.Tz.value;
% Safely extract model parameters if they exist
if isfield(model, 'Tp1')
 fprintf('P T1 model = %2.3g sec \n', getfield(model, 'Tp1'));
end
if isfield(model, 'Tp2')
 fprintf('P T2 model = %2.3g sec \n', getfield(model, 'Tp2'));
end
if isfield(model, 'Tp3')
 fprintf('P T3 model = %2.3g sec \n', getfield(model, 'Tp3'));
end
if isfield(model, 'Tz')
 fprintf('Z T1 model = %2.3g sec \n', getfield(model, 'Tz'));
end
if isfield(model, 'Td')
 fprintf('Delay model = %2.3g sec \n', getfield(model, 'Td'));
end
if isfield(model, 'Kp')
 fprintf('Gain model = %2.3g \n', getfield(model, 'Kp'));
end


% Plot stepresponse geschatte model
step_out_est=step(H_EST, t_pre);
% Shift Ntrig samples to the right (Ntrig = moment of step on input)
% using a temp variable a
a=step_out_est;
a(1:N)=step_out_est(1);
a(Ntrig+1:N)=step_out_est(1:N-Ntrig);
step_out_est=a;
clear a;

%% plotting
%plot difference between measured step and estimated model
h=figure(102); set(h,'WindowStyle','docked');
plot(t_pre, step_out_est-y_pre, 'red');
grid on;
title('Difference between measured step and estimated model');
%
h=figure(103); set(h,'WindowStyle','docked');
plot(t_pre, y_pre,t_pre, step_out_est, 'red');
grid on;
title('Measured Stepresponse and stepresponse from estimated model (red)');

end