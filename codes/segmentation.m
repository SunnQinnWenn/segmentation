% Use the surrounding pixels to predict the whether a pixel is part of 
% a mitochondrion

%% Initialization
clear ; close all; clc

%% Set up the variables and constants
loadVariables;

%% Load Data 
fprintf('\nLoading Data ...\n')

loadinputs;

%% Initializing Pameters

fprintf('\nInitializing Neural Network Parameters ...\n')

initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer1_size);
initial_Theta2 = randInitializeWeights(hidden_layer1_size, output_layer_size);

% Unroll parameters
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];


%%  Gradient checking 
% 
% fprintf('\nChecking Backpropagation (w/ Regularization) ... \n')
% 
% % Check gradients by running checkNNGradients
% checkNNGradients_MA(lambda);
%  
% fprintf('Program paused. Press enter to continue.\n');
% pause;


%% Training NN 

fprintf('\nTraining Neural Network... \n');

options = optimset('MaxIter', max_runs);

% Create "short hand" for the cost function to be minimized
costFunction = @(p) nnCostFunction_MA(p, ...
                                   input_layer_size, ...
                                   hidden_layer1_size, ...
                                   output_layer_size, X_training, y_training, lambda);

% Now, costFunction is a function that takes in only one argument (the
% neural network parameters)
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% Obtain Theta1, Theta2 back from nn_params
Theta1_size = hidden_layer1_size * (input_layer_size + 1);

Theta1 = reshape(nn_params(1:Theta1_size), ...
                 hidden_layer1_size, (input_layer_size + 1));
             
Theta2 = reshape(nn_params((1 + Theta1_size): end), ...
                 output_layer_size, (hidden_layer1_size + 1));



%% results 

% predict 
fprintf('\npredict training dataset: \n');
training_pred = predict(Theta1, Theta2, X_training, threshold, y_training);
compare_result(training_pred, y_training, threshold);

fprintf('\npredict new dataset: \n');
test_pred = predict(Theta1, Theta2, X_test, threshold, y_test);
compare_result(test_pred, y_test, threshold);

% analysis
training_pred = (training_pred >= threshold);
test_pred = (test_pred >= threshold);
[training_accuracy, training_precision, training_recall, training_F_score] = errorAnalysis(training_pred, y_training);
[test_accuracy, test_precision, test_recall, test_F_score] = errorAnalysis(test_pred, y_test);

% dispay results
fprintf('\nTraining, test set accuracy, precision, recall, F_score: \n');
fprintf('%f\n', training_accuracy * 100);
fprintf('%f\n', training_precision * 100);
fprintf('%f\n', training_recall * 100);
fprintf('%f\n', training_F_score * 100);
fprintf('\n');
fprintf('%f\n', test_accuracy * 100);
fprintf('%f\n', test_precision * 100);
fprintf('%f\n', test_recall * 100);
fprintf('%f\n', test_F_score * 100);

