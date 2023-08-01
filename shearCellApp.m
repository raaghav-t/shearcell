function shearCellApp

% Define Variables
frequency = 1;
voltage   = 0;
time      = 0 - 1/frequency;

fig = uifigure('WindowState','fullscreen', ...
    'Name','Plot App by Raaghav');
g = uigridlayout(fig,[6 6], 'BackgroundColor',[222/255 255/255 241/255]);
g.RowHeight = {'1x','2x','2x','2x','2x','1x'};
g.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};

% Plots to visualize data as its collected
% Voltage versus steps
axisVoltStep = uiaxes(g);
axisVoltStep.Layout.Row = [2 5];
axisVoltStep.Layout.Column = [1 6];
axisVoltStep.Title.String = 'Voltage Versus Time';
axisVoltStep.XLabel.String = 'Time (s)';
axisVoltStep.YLabel.String = 'Voltage (V)';

% Interactable elements
% Button to aquire the next datapoint and plot it

recordButton = uibutton(g, ...
    "Text","Begin Recording", ...
    "ButtonPushedFcn", @(src,event) recordButtonPushed(), ...
    "BackgroundColor", [0.5 1 0.5]);
recordButton.Layout.Row = 6;
recordButton.Layout.Column = 1;

% Test
testButton = uibutton(g, ...
    "Text","Test", ...
    "ButtonPushedFcn", @(src,event) testButtonPushed(), ...
    "BackgroundColor", [0.5 1 0.5]);
testButton.Layout.Row = 6;
testButton.Layout.Column = 2;

% Button that saves data to a csv
saveButton = uibutton(g, ...
    "Text","Save", ...
    "ButtonPushedFcn", @(src,event) saveButtonPushed(),...
    "BackgroundColor",[149, 252, 158]/255);
saveButton.Layout.Row = 6;
saveButton.Layout.Column = 5;

% Button that ends live feed
endButton = uibutton(g, ...
    "Text","End Live", ...
    "ButtonPushedFcn", @(src,event) endButtonPushed(), ...
    "BackgroundColor",[242/255 19/255 83/255]);
endButton.Layout.Row = 6;
endButton.Layout.Column = 6;

% Panel to display latest value
valuePanel = uipanel(g, ...
    "Title","Latest Value", ...
    "BackgroundColor",[184/255 255/255 242/255]);
valuePanel.Layout.Row = 1;
valuePanel.Layout.Column = [1 2];
valuePanelValue = uilabel(valuePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
valuePanelValue.Position(3:4) = [80 44];

% Panel to display live value
livePanel = uipanel(g, ...
    "Title","Live Value", ...
    "BackgroundColor",[184/255 255/255 242/255]);
livePanel.Layout.Row = 1;
livePanel.Layout.Column = [3 4];
livePanelValue = uilabel(livePanel, ...
    "Text", 'waiting...', ...
    "HorizontalAlignment", 'center', ...
    "VerticalAlignment", 'center');
livePanelValue.Position(3:4) = [80 44];

% Dropdown menu that chooses steps taken with crank
stepSelector = uidropdown(g, ...
    'BackgroundColor',[222/255 255/255 241/255]);
stepSelector.Layout.Row = 1;
stepSelector.Layout.Column = 6;
stepSelector.Items = {'2', '1', '0.5'};
stepSelector.Value = '2';

% Field that allows you to change filename (first half)
discType = uieditfield(g, "Value", 'set material', ...
    'BackgroundColor',[229/255 202/255 250/255]);
discType.Layout.Row = 6;
discType.Layout.Column = 3;

% Field that allows you to change filename (second half)
stationType = uieditfield(g, "Value", 'set load (N)', ...
    'BackgroundColor',[229/255 202/255 250/255]);
stationType.Layout.Row = 6;
stationType.Layout.Column = 4;


% Initialize voltage - step plot data
voltY     = [];
timeX     = [];

% Arduino serial read
serial = serialport("/dev/cu.usbmodem2101", 57600);
configureTerminator(serial,"CR/LF");
flush(serial);
serial.UserData = struct("Data",[],"Count",1);

stateA = 0;

    function testButtonPushed()
        stateA = 1;
        while stateA == 1
            % Define voltage and time
            voltage   = readVoltage(a,'A3') - readVoltage(a,'A2');
            time      = time + 1/frequency;

            % Append the voltstep data to the cumulative data
            voltY     = [voltY, voltage];
            timeX     = [timeX, time];

            % Update panel value
            valuePanelValue.Text = sprintf('%5.3f',voltage);
            livePanelValue.Text = sprintf('%5.3f',voltage);

            % Plot the cumulative data
            plot(axisVoltStep, timeX, voltY);
            pause(1/frequency);
        end
    end

    function recordButtonPushed()
        stateA = 1;
        while stateA == 1
            % Read the ASCII data from the serialport object.
            data = readline(serial);

            % Convert the string data to numeric type and save it in the UserData
            % property of the serialport object.
            serial.UserData.Data(end+1) = str2double(data);

            % Update the Count value of the serialport object.
            serial.UserData.Count = serial.UserData.Count + 1;

            % Data is ploted
            configureCallback(serial, "off");
            plot(axisVoltStep,serial.UserData.Data(2:end));
        end
    end

    function saveButtonPushed()
        data = [voltY(:), timeX(:)];

        fileName1  = discType.Value;
        fileName2  = stationType.Value;
        formatSpec = '%s%s.csv';

        locationName = sprintf(formatSpec,fileName1,fileName2);

        writematrix(data, locationName)
        saveButton.Text = 'Saved';
        saveButton.BackgroundColor = [252 242 149]/255;
    end

    function endButtonPushed()
            stateA = 0;
            endButton.Text = 'Recording Ended';
            endButton.BackgroundColor = [252 207 149]/255;
    end
end