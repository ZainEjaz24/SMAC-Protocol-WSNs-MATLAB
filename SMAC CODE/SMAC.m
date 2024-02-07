% SMAC (Sensors Medium Access Control) PROTOCOL FOR WIRELESS SENSOR NETWORKS%
% IMPLEMENTED BY LARAIB AZMAT AND ZAIN EJAZ


% Comprehensive S-MAC Simulation with Visualization in MATLAB

% Parameters
totalNodes = 10; % Total number of nodes in the network
simulationTime = 100; % Simulation time in seconds
packetSize = 100; % Size of each data packet in bytes
trafficLoad = 0.6; % Probability of a sensing event occurring

% Initialize node states
sleepDuration = zeros(1, totalNodes); % Array to store sleep duration for each node
transmissionTime = zeros(1, totalNodes); % Array to store transmission time for each node

% Packet aggregation parameters
aggregatedPackets = zeros(1, totalNodes); % Initialize an array to store aggregated packets for each node

% Dynamic sleep adjustment parameters
SleepPeriod = 3; % fixed sleep duration of node
syncInterval = 50; % Synchronization interval
AwakePeriods = syncInterval - SleepPeriod;

% Duty cycle parameters
currentDutyCycle = 0.1; % Initial duty cycle

% Synchronization parameters
syncDuration = 1; % Duration for which SYNC is transmitted
rtsThreshold = 0.5; % RTS threshold for initiating RTS/CTS
rtsDuration = 2; % Duration for which RTS is transmitted
ctsDuration = 1; % Duration for which CTS is transmitted
syncPeriod = 10; % Synchronization period for sending SYNC packets periodically

% Virtual cluster parameters
numVirtualClusters = 3; % Number of virtual clusters
nodesPerCluster = round(totalNodes / numVirtualClusters); % Number of nodes per virtual cluster

% Assign nodes to virtual clusters
virtualClusters = cell(1, numVirtualClusters); % Create a cell array to store virtual clusters
for i = 1:numVirtualClusters % Iterate over the number of virtual clusters
    % Define the range of nodes for the current virtual cluster
    virtualClusters{i} = (i-1)*nodesPerCluster + 1 : i*nodesPerCluster;
end


% Simulation loop
for time = 1:simulationTime % Loop over simulation time
    for senderCluster = 1:numVirtualClusters % Loop over each virtual cluster as a potential sender
        clusterNodes = virtualClusters{senderCluster}; % Get the nodes within the sender cluster
        for j = 1:length(clusterNodes) % Loop over nodes within the cluster
            senderNode = clusterNodes(j); % Get the node index
            % Check if senderNode is a positive integer and within the range of totalNodes
            if ~isscalar(senderNode) || senderNode < 1 || senderNode > totalNodes || mod(senderNode, 1) ~= 0
                error('Invalid senderNode index: %d', senderNode);
            end
            % Check if a sensing event occurs
            if rand() < trafficLoad
                % Check if the node is awake before transmission
                if sleepDuration(senderNode) == 0
                    % SYNC phase: Send SYNC packets periodically
                    if mod(time, syncPeriod) == 0
                        disp(['Node ' num2str(senderNode) ' sends SYNC at time ' num2str(time)]);
                        transmissionTime(senderNode) = transmissionTime(senderNode) + syncDuration;
                        % Broadcast SYNC packet to neighbors
                        for neighborNode = virtualClusters{senderCluster}
                            if neighborNode ~= senderNode && rand() < rtsThreshold
                                disp(['Node ' num2str(neighborNode) ' receives SYNC from Node ' num2str(senderNode)]);
                                % RTS phase: Neighbor initiates RTS
                                disp(['Node ' num2str(neighborNode) ' initiates RTS at time ' num2str(time)]);
                                transmissionTime(neighborNode) = transmissionTime(neighborNode) + rtsDuration;
                                % Neighbor responds with CTS
                                disp(['Node ' num2str(senderNode) ' sends CTS at time ' num2str(time)]);
                                transmissionTime(senderNode) = transmissionTime(senderNode) + ctsDuration;
                                % Continue with data transmission
                                disp(['Node ' num2str(neighborNode) ' transmits data after RTS/CTS at time ' num2str(time)]);
                                transmissionTime(neighborNode) = transmissionTime(neighborNode) + packetSize;
                                aggregatedPackets(neighborNode) = aggregatedPackets(neighborNode) + 1;
                            end
                        end
                    end
                else
                    % Node is asleep, no transmission
                    disp(['Node ' num2str(senderNode) ' is asleep at time ' num2str(time)]);
                end
            else
                % No sensing event, increase sleep duration
                sleepDuration(senderNode) = sleepDuration(senderNode) + 1;
                % Update sleep duration based on duty cycle
                if sleepDuration(senderNode) >= SleepPeriod
                    sleepDuration(senderNode) = 0;
                end
            end
        end
    end
    
    % Adjust duty cycle based on fixed sleep and awake periods
    currentDutyCycle = sum(AwakePeriods) / syncInterval;

   % Plot node states
subplot(8, 1, 1); % Create a subplot in the 1st position of an 8-row grid with one column
plot(1:totalNodes, transmissionTime, 'o-', 'LineWidth', 1.5); % Plot the transmission time for each node
title('Transmission Time'); % Set the title of the subplot
xlabel('Node'); % Label the x-axis as "Node"
ylabel('Time (s)'); % Label the y-axis as "Time (s)"

    
    subplot(8, 1, 3);
    plot(1:totalNodes, sleepDuration, 'o-', 'LineWidth', 1.5); %%The option 'o-' specifies the line style (solid line with circles at data points)
    title('Sleep Duration');
    xlabel('Node');
    ylabel('Time (s)');
    
    subplot(8, 1, 5);
    plot(1:totalNodes, aggregatedPackets, 'o-', 'LineWidth', 1.5);
    title('Aggregated Packets');
    xlabel('Node');
    ylabel('Number of Packets');
    
    subplot(8, 1, 7);
    plot(time, currentDutyCycle, 'o-', 'LineWidth', 1.5);
    title('Current Duty Cycle');
    xlabel('Time (s)');
    ylabel('Duty Cycle');
    
    pause(0.5); % Pause to observe the plot
end

% Calculate overall network statistics
totalTransmissionTime = sum(transmissionTime);
energyConsumption = totalTransmissionTime;

% Display network-wide statistics
disp(' ');
disp('Network-wide Statistics:');
disp('-------------------------');
disp(['Total Transmission Time: ' num2str(totalTransmissionTime)]);
disp(['Total Energy Consumption: ' num2str(energyConsumption)]);