%% Use this code to generate the important parameters and variables(as timetables)
% Timetables generated by this code:
    % 1. minpwu020200129
    % 2. secpwu020200129
    % 3. new_table_pwu020200129
    % 4. new_table_pwu020200129_soc30to40    %these last 4 variables can change from dataset to dataset
    % 5. new_table_pwu020200129_soc40to50
    % 6. new_table_pwu020200129_soc50to60
    % 7. new_table_pwu020200129_soc60to70
    
% Run section-by-section for now. Don't run the complete code.

        % CREATION OF minpwu020200129
% 1. Manually import DateTime and SOC values as table from min file (in col 1&2 resp.)

        % CREATION OF secpwu020200129
% 2. Manually import DateTime and CurrTotal values as table from sec file (in col 1&2 resp.)
% 3. Manually import DateTime and VoltTotal values as table from sec file (in col 1&2 resp.)
% 4. Add CurrTotal values to 3rd column of voltage table and clear currTotal table

        % CREATION OF new_table
% 5. Convert min and sec table to timetable
% 6. Synchronize both the tables and interpolate all NaN values  
% 7. Add delta_V and delta_i values to new_table_pwu020200129 (in col 4&5 resp.)
% 8. Add Power to new_table_pwu020200129 (in col 6)
% 9. Add C-rate to new_table_pwu020200129 (in col 7)

        % CREATION OF last 4 variables
% 10. Filter new_table_pwu020200129 according to SoC ranges

        % CREATION OF new_table_pwu020200130_Crate
% 11. Filter new_table_pwu020200130 according to C_rate


        % CREATION OF V_SoC_fit (struct variable)
% 12. Create V vs SoC fit variables

%% 1. Manually import DateTime and SOC values as table from min file (in col 1&2 resp.)
% extract SoC values from raw strings

PWU0prcSoc = minpwu020200130.PWU0prcSoc;
PWU0prcSoc = extractBetween(PWU0prcSoc,'<a type ="10"><i>','</i>');
PWU0prcSoc = replace(PWU0prcSoc, "," , ".");
PWU0prcSoc = str2double(PWU0prcSoc);

minpwu020200130.PWU0prcSoc = PWU0prcSoc;

clearvars PWU0prcSoc

%% 2. Manually import DateTime and CurrTotal values as table from sec file (in col 1&2 resp.)
% 3. Manually import DateTime and VoltTotal values as table from sec file (in col 1&2 resp.) 
% 4. Add CurrTotal values to 3rd column of voltage table and clear currTotal table - run section

secpwu020200130_volt{:,3} = secpwu020200130_curr{:,2};
secpwu020200130_volt.Properties.VariableNames{3} = 'PWU0STRSTR0MDL0prcCurrTotal';
clear secpwu020200130_curr
% now rename your workspace variables if needed (i.e. remove the '_volt' suffix)

%% Change Variable name of DateTime column of secpwu020200129 and minpwu020200129 to 'Time'

secpwu020200130.Properties.VariableNames{1} = 'Time';
minpwu020200130.Properties.VariableNames{1} = 'Time';

%% 5. Convert min and sec table to timetable
%convert from type table to type timetable

minpwu020200130 = table2timetable(minpwu020200130);
secpwu020200130 = table2timetable(secpwu020200130);

%% 6. Synchronize both the tables and interpolate all NaN values  ;
new_table_pwu020200130 = synchronize(secpwu020200130,minpwu020200130,'union','linear'); %seconds resolution

%% 7. Add delta_V and delta_i values to new_table_pwu020200130 (in col 4&5 resp.)

%this section adds delta_V values to 4th column of new_table_pwu020200130
volt_vals = new_table_pwu020200130.PWU0STRSTR0MDL0prcVoltTotal;
delta_V = zeros(1, length(volt_vals));      %initializing the array
for k = 1:length(volt_vals)-1
    delta_V(k+1) = volt_vals(k+1)-volt_vals(k);
end
delta_V = transpose(delta_V);
delta_V = table(delta_V);
new_table_pwu020200130(:,4) = delta_V;
new_table_pwu020200130.Properties.VariableNames{4} = 'delta_V';
clear volt_vals delta_V k

%this section adds delta_i values to the 5th column of new_table_pwu020200130
curr_vals = new_table_pwu020200130.PWU0STRSTR0MDL0prcCurrTotal;
delta_i = zeros(1, length(curr_vals));
for k = 1:length(curr_vals)-1
    delta_i(k+1) = curr_vals(k+1)-curr_vals(k);
end
delta_i = transpose(delta_i);
delta_i = table(delta_i);
new_table_pwu020200130(:,5) = delta_i;
new_table_pwu020200130.Properties.VariableNames{5} = 'delta_i';
clear curr_vals k delta_i

%% 8. Add Power to new_table_pwu020200129 (in col 6)

new_table_pwu020200130(:,6) = array2table((new_table_pwu020200130.PWU0STRSTR0MDL0prcVoltTotal.* ...
                                            new_table_pwu020200130.PWU0STRSTR0MDL0prcCurrTotal)./1000);
new_table_pwu020200130.Properties.VariableNames{6} = 'Power';

%% 9. Add C-rate to new_table_pwu020200129 (in col 7)

Qmax = 94;  %Ah
new_table_pwu020200130.C_rate = new_table_pwu020200130.PWU0STRSTR0MDL0prcCurrTotal / Qmax;

%% 10. Filter new_table_pwu020200129 according to SoC ranges
tic
% sort new_table in ascending order of SoC
new_table_pwu020200130 = sortrows(new_table_pwu020200130,'PWU0prcSoc','ascend');

%fill new_table_soc30to40
a = 1; 
k = 1;
while new_table_pwu020200130{k,3} >= 30 && new_table_pwu020200130{k,3} < 40
    k = k+1;
end
new_table_pwu020200130_soc30to40 = new_table_pwu020200130(a:k-1,:); 

%fill new_table_soc40to50
a = k;
while new_table_pwu020200130{k,3} >= 40 && new_table_pwu020200130{k,3} < 50
    k = k+1;
end
new_table_pwu020200130_soc40to50 = new_table_pwu020200130(a:k-1,:);

%fill new_table_soc50to60
a = k;
while new_table_pwu020200130{k,3} >= 50 && new_table_pwu020200130{k,3} < 60 && k<height(new_table_pwu020200130)
    k = k+1;
end
new_table_pwu020200130_soc50to60 = new_table_pwu020200130(a:k,:);
%%
%fill new_table_soc60to70
a = k;
while new_table_pwu020200130{k,3} >= 60 && new_table_pwu020200130{k,3} < 70 && k<height(new_table_pwu020200130)
    k = k+1;
end
new_table_pwu020200130_soc60to70 = new_table_pwu020200130(a:k,:);

clear k a
toc

%% 11. Filter new_table_pwu020200130 according to C_rate
tic
% sort new_table_pwu020200130 in ascending order of C_rate
new_table_pwu020200130 = sortrows(new_table_pwu020200130,'C_rate','ascend');

%fill new_table_pwu020200130_Crate.np4tonp3
a = 1; 
k = 1;
while new_table_pwu020200130{k,7} >= -0.4 && new_table_pwu020200130{k,7} < -0.3
    k = k+1;
end
new_table_pwu020200130_Crate.np4tonp3 = new_table_pwu020200130(a:k-1,:); %C_rate neg point 4 to neg point 3 - this is how you read it

%fill new_table_pwu020200130_Crate.np3tonp2
a = k;
while new_table_pwu020200130{k,7} >= -0.3 && new_table_pwu020200130{k,7} < -0.2
    k = k+1;
end
new_table_pwu020200130_Crate.np3tonp2 = new_table_pwu020200130(a:k-1,:);

%fill new_table_pwu020200130_Crate.np2tonp1
a = k;
while new_table_pwu020200130{k,7} >= -0.2 && new_table_pwu020200130{k,7} < -0.1
    k = k+1;
end
new_table_pwu020200130_Crate.np2tonp1 = new_table_pwu020200130(a:k-1,:);

%fill new_table_pwu020200130_Crate.np1tozero
a = k;
while new_table_pwu020200130{k,7} >= -0.1 && new_table_pwu020200130{k,7} < 0
    k = k+1;
end
new_table_pwu020200130_Crate.np1tozero = new_table_pwu020200130(a:k-1,:);

%fill new_table_pwu020200130_Crate.zerotopp1
a = k;
while new_table_pwu020200130{k,7} >= 0 && new_table_pwu020200130{k,7} < 0.1
    k = k+1;
end
new_table_pwu020200130_Crate.zerotopp1 = new_table_pwu020200130(a:k-1,:);

%fill new_table_pwu020200130_Crate.pp1topp2
a = k;
while new_table_pwu020200130{k,7} >= 0.1 && new_table_pwu020200130{k,7} < 0.2
    k = k+1;
end
new_table_pwu020200130_Crate.pp1topp2 = new_table_pwu020200130(a:k-1,:);

%fill new_table_pwu020200130_Crate.pp2topp3
a = k;
while new_table_pwu020200130{k,7} >= 0.2 && new_table_pwu020200130{k,7} < 0.3
    k = k+1;
end
new_table_pwu020200130_Crate.pp2topp3 = new_table_pwu020200130(a:k-1,:);

%fill new_table_pwu020200130_Crate.pp3topp4
a = k;
while new_table_pwu020200130{k,7} >= 0.3 && new_table_pwu020200130{k,7} < 0.4
    k = k+1;
end
new_table_pwu020200130_Crate.pp3topp4 = new_table_pwu020200130(a:k-1,:);

%fill new_table_pwu020200130_Crate.pp4topp5
a = k;
while new_table_pwu020200130{k,7} >= 0.4 && new_table_pwu020200130{k,7} < 0.5 && k<height(new_table_pwu020200130)
    k = k+1;
end
new_table_pwu020200130_Crate.pp4topp5 = new_table_pwu020200130(a:k,:);

clear k a
toc

%% 12. Create V vs SoC fit variables

% 1st output argument returns the type cfit variable
% 2nd output argument returns goodness-of-fit statistics in a structure of the same name
% 1st input argument: x values
% 2nd input argument: y values
% 3rd input argument: fit type
%plot Soc vs Voltage when -0.4 < C_rate < -0.3
[V_SoC_fit.C_rate_np4tonp3, V_SoC_fit.C_rate_np4tonp3_GOF] = fit(new_table_pwu020200130_Crate.np4tonp3.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.np4tonp3.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when -0.3 < C_rate < -0.2
[V_SoC_fit.C_rate_np3tonp2, V_SoC_fit.C_rate_np3tonp2_GOF] = fit(new_table_pwu020200130_Crate.np3tonp2.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.np3tonp2.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when -0.2 < C_rate < -0.1
[V_SoC_fit.C_rate_np2tonp1, V_SoC_fit.C_rate_np2tonp1_GOF] = fit(new_table_pwu020200130_Crate.np2tonp1.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.np2tonp1.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when -0.1 < C_rate < 0
[V_SoC_fit.C_rate_np1tozero, V_SoC_fit.C_rate_np1tozero_GOF] = fit(new_table_pwu020200130_Crate.np1tozero.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.np1tozero.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when 0 < C_rate < 0.1
[V_SoC_fit.C_rate_zerotopp1, V_SoC_fit.C_rate_zerotopp1_GOF] = fit(new_table_pwu020200130_Crate.zerotopp1.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.zerotopp1.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when 0.1 < C_rate < 0.2
[V_SoC_fit.C_rate_pp1topp2, V_SoC_fit.C_rate_pp1topp2_GOF] = fit(new_table_pwu020200130_Crate.pp1topp2.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.pp1topp2.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when 0.2 < C_rate < 0.3
[V_SoC_fit.C_rate_pp2topp3, V_SoC_fit.C_rate_pp2topp3_GOF] = fit(new_table_pwu020200130_Crate.pp2topp3.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.pp2topp3.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when 0.3 < C_rate < 0.4
[V_SoC_fit.C_rate_pp3topp4, V_SoC_fit.C_rate_pp3topp4_GOF] = fit(new_table_pwu020200130_Crate.pp3topp4.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.pp3topp4.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');
%plot Soc vs Voltage when 0.4 < C_rate < 0.5
[V_SoC_fit.C_rate_pp4topp5, V_SoC_fit.C_rate_pp4topp5_GOF] = fit(new_table_pwu020200130_Crate.pp4topp5.PWU0prcSoc, ...
                                                   new_table_pwu020200130_Crate.pp4topp5.PWU0STRSTR0MDL0prcVoltTotal, 'gauss2');

%% 13. Add delta_V and delta_i values to new_table_pwu020200130_step (in col 4&5 resp.)

tic
%this section adds delta_i values to the 4th column of new_table_pwu020200130
curr_vals               = new_table_pwu020200130.PWU0STRSTR0MDL0prcCurrTotal;
currentSignCheck_range  = 10;
curr_vals_step          = NaN(length(curr_vals), 1);
curr_vals_step(1)       = curr_vals(1);
delta_i                 = zeros(length(curr_vals), 1);

a1_predef = logical(ones(currentSignCheck_range, 1));     %ones(no. of rows, no. of columns)
step_indices = 1; %initialization
curr_vals_step_indices = curr_vals(step_indices);

i = 2;
i_vals = i;

while i <= length(curr_vals)
    if curr_vals(i) ~= 0
        %comparing sign of 'current' current value with the 'previous' current value
        if sign(curr_vals(i)) == sign(curr_vals(i-1))   % if sign is same, then skip over (do nothing)
    %         sprintf('no step change skip over - 1')
            i = i+1;
        else        %SIGN CHANGE - we start comparing sign of i-th current value to sign of next ten current values
            a1 = (sign(curr_vals(i)) == sign(curr_vals(i+1:(i+currentSignCheck_range)))); %a1 is a logical array
            % now come the if-else statements which define if a sign change is a valid step change or not
            % if sign of i-th current value is equal to sign of next ten current values, VALID STEP CHANGE
            if isequal(a1, a1_predef)   % if sign is same, then is a VALID STEP CHANGE
                curr_vals_step(i-1) = curr_vals(i-1);   %record the (i-1)th current value
                curr_vals_step(i) = curr_vals(i);       %record the i-th current value
                step_indices = [step_indices; i-1; i];  %record the indices of that step
                curr_vals_step_indices = curr_vals(step_indices);
    %             sprintf('valid step change - 2')
                i = i+1;
            else    % now MAYBE it's a valid step change ... maybe not. WE DON'T KNOW. Analyze no. of zeros in a1 (the logical array)
                a1_numberofzeros = nnz(~a1);
                a1_numberofzeros_percentage = (a1_numberofzeros/length(a1))*100;
                if a1_numberofzeros_percentage > 50     %NOT A VALID STEP CHANGE - JUMP 
                    jump = i;
                    while jump <= i+11
                        if sign(curr_vals(jump)) ~= sign(curr_vals(i-1))
                            jump = jump+1;
                        else
                            i = jump+1;
                            break
                        end
                    end
    %                 sprintf('not a valid step change - jump over - 3')
                else
                    a1 = (sign(curr_vals(i)) == sign(curr_vals(i+1:(i+currentSignCheck_range+15))));
                    a1_numberofzeros = nnz(~a1);
                    a1_numberofzeros_percentage = (a1_numberofzeros/length(a1))*100;
                    if a1_numberofzeros_percentage <= 50        %VALID STEP CHANGE
                        curr_vals_step(i-1) = curr_vals(i-1);   %record the (i-1)th current value
                        curr_vals_step(i) = curr_vals(i);       %record the i-th current value
                        step_indices = [step_indices; i-1; i];  %record the indices of that step
                        curr_vals_step_indices = curr_vals(step_indices);
    %                     sprintf('valid step change - 4')
                        i = i+1;
                    else    %NOT A VALID STEP CHANGE - JUMP 
                        jump = i;
                        while jump <= i+11
                            if sign(curr_vals(jump)) ~= sign(curr_vals(i-1))
                                jump = jump+1;
                            else
                                i = jump+1;
                                break
                            end
                        end
    %                     sprintf('not a valid step change - jump over - 5')
                    end
                end
            end
        end
    else
        curr_vals(i) = 0.01*sign(curr_vals(i-1));
        %comparing sign of 'current' current value with the 'previous' current value
        if sign(curr_vals(i)) == sign(curr_vals(i-1))   % if sign is same, then skip over (do nothing)
    %         sprintf('no step change skip over - 1')
            i = i+1;
        else        %SIGN CHANGE - we start comparing sign of i-th current value to sign of next ten current values
            a1 = (sign(curr_vals(i)) == sign(curr_vals(i+1:(i+currentSignCheck_range)))); %a1 is a logical array
            % now come the if-else statements which define if a sign change is a valid step change or not
            % if sign of i-th current value is equal to sign of next ten current values, VALID STEP CHANGE
            if isequal(a1, a1_predef)   % if sign is same, then is a VALID STEP CHANGE
                curr_vals_step(i-1) = curr_vals(i-1);   %record the (i-1)th current value
                curr_vals_step(i) = curr_vals(i);       %record the i-th current value
                step_indices = [step_indices; i-1; i];  %record the indices of that step
                curr_vals_step_indices = curr_vals(step_indices);
    %             sprintf('valid step change - 2')
                i = i+1;
            else    % now MAYBE it's a valid step change ... maybe not. WE DON'T KNOW. Analyze no. of zeros in a1 (the logical array)
                a1_numberofzeros = nnz(~a1);
                a1_numberofzeros_percentage = (a1_numberofzeros/length(a1))*100;
                if a1_numberofzeros_percentage > 50     %NOT A VALID STEP CHANGE - JUMP 
                    jump = i;
                    while jump <= i+11
                        if sign(curr_vals(jump)) ~= sign(curr_vals(i-1))
                            jump = jump+1;
                        else
                            i = jump+1;
                            break
                        end
                    end
    %                 sprintf('not a valid step change - jump over - 3')
                else
                    a1 = (sign(curr_vals(i)) == sign(curr_vals(i+1:(i+currentSignCheck_range+15))));
                    a1_numberofzeros = nnz(~a1);
                    a1_numberofzeros_percentage = (a1_numberofzeros/length(a1))*100;
                    if a1_numberofzeros_percentage <= 50        %VALID STEP CHANGE
                        curr_vals_step(i-1) = curr_vals(i-1);   %record the (i-1)th current value
                        curr_vals_step(i) = curr_vals(i);       %record the i-th current value
                        step_indices = [step_indices; i-1; i];  %record the indices of that step
                        curr_vals_step_indices = curr_vals(step_indices);
    %                     sprintf('valid step change - 4')
                        i = i+1;
                    else    %NOT A VALID STEP CHANGE - JUMP 
                        jump = i;
                        while jump <= i+11
                            if sign(curr_vals(jump)) ~= sign(curr_vals(i-1))
                                jump = jump+1;
                            else
                                i = jump+1;
                                break
                            end
                        end
    %                     sprintf('not a valid step change - jump over - 5')
                    end
                end
            end
        end
    end
    i_vals = [i_vals;i];
end
toc

clear a1 a1_numberofzeros a1_numberofzeros_percentage a1_predef ans
clear curr_vals curr_vals_step curr_vals_step_indices currentSignCheck_range delta_i
clear i i_vals jump step_indices
%%
for k = 1:length(curr_vals)-1
    delta_i(k+1) = curr_vals(k+1)-curr_vals(k);
end
delta_i = transpose(delta_i);
delta_i = table(delta_i);
new_table_pwu020200130(:,5) = delta_i;
new_table_pwu020200130.Properties.VariableNames{5} = 'delta_i';
clear curr_vals k delta_i

toc

%this section adds delta_V values to 5th column of new_table_pwu020200130
volt_vals = new_table_pwu020200130.PWU0STRSTR0MDL0prcVoltTotal;
delta_V = zeros(1, length(volt_vals));      %initializing the array
for k = 1:length(volt_vals)-1
    delta_V(k+1) = volt_vals(k+1)-volt_vals(k);
end
delta_V = transpose(delta_V);
delta_V = table(delta_V);
new_table_pwu020200130(:,4) = delta_V;
new_table_pwu020200130.Properties.VariableNames{4} = 'delta_V';
clear volt_vals delta_V k