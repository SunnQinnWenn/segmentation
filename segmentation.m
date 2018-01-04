%% Initialization
clear ; close all; clc

%% Setup the parameters you will use for this exercise
height = 3000;
width = 3000;
x_interval = 251;
y_interval = 251;
lambda = 2;

input_layer_size  = x_interval * y_interval; 
hidden_layer1_size = 25;   % 25 hidden units
% output_layer_size = input_layer_size;
output_layer_size = 1;

%% =========== Part 0: Loading Data =============

fprintf('\nLoading Data ...\n')

loadinputs;
% pause;

%% ================ Part 1: Initializing Pameters ================
%  In this part of the exercise, you will be starting to implment a two
%  layer neural network that classifies digits. You will start by
%  implementing a function to initialize the weights of the neural network
%  (randInitializeWeights.m)

fprintf('\nInitializing Neural Network Parameters ...\n')

initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer1_size);
initial_Theta2 = randInitializeWeights(hidden_layer1_size, output_layer_size);


% Unroll parameters
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];



%% =============== Part 2: Gradient checking ===============
%  Once your backpropagation implementation is correct, you should now
%  continue to implement the regularization with the cost and gradient.
% %
% 
% fprintf('\nChecking Backpropagation (w/ Regularization) ... \n')
% 
% % Check gradients by running checkNNGradients
% lambda = 0.05;
% checkNNGradients_MA(lambda);
%  
% fprintf('Program paused. Press enter to continue.\n');
% % pause;

%% =================== Part 3: Training NN ===================
%  You have now implemented all the code necessary to train a neural 
%  network. To train your neural network, we will now use "fmincg", which
%  is a function which works similarly to "fminunc". Recall that these
%  advanced optimizers are able to train our cost functions efficiently as
%  long as we provide them with the gradient computations.
%
fprintf('\nTraining Neural Network... \n')

%  After you have completed the assignment, change the MaxIter to a larger
%  value to see how more training helps.
options = optimset('MaxIter', 100);

%  You should also try different values of lambda
% lambda = 3;

% Create "short hand" for the cost function to be minimized
costFunction = @(p) nnCostFunction_MA(p, ...
                                   input_layer_size, ...
                                   hidden_layer1_size, ...
                                   output_layer_size, X, y, lambda);

% Now, costFunction is a function that takes in only one argument (the
% neural network parameters)
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);


% Obtain Theta1, Theta2 back from nn_params
Theta1_size = hidden_layer1_size * (input_layer_size + 1);

Theta1 = reshape(nn_params(1:Theta1_size), ...
                 hidden_layer1_size, (input_layer_size + 1));
             
Theta2 = reshape(nn_params((1 + Theta1_size): end), ...
                 output_layer_size, (hidden_layer1_size + 1));

fprintf('Program paused. Press enter to continue.\n');
% pause;


%% ================= Part 4: Implement Predict =================
%  After training the neural network, we would like to use it to predict
%  the labels. You will now implement the "predict" function to use the
%  neural network to predict the labels of the training set. This lets
%  you compute the training set accuracy.
threshold = 0.5;
fprintf('\npredict training dataset: \n');
pred = predict_MA(Theta1, Theta2, X, y, threshold);
[accuracy, precision, recall, F_score] = errorAnalysis(pred, y);


% pause;
fprintf('\nTraining Set Accuracy: %f\n', accuracy * 100);
fprintf('\nTraining Set precision: %f\n', precision * 100);
fprintf('\nTraining Set recall: %f\n', recall * 100);
fprintf('\nTraining Set F_score: %f\n', F_score * 100);

%% ================= Part 10: Predict new examples =================
fprintf('\npredict new dataset: \n');

test_pred = predict_MA(Theta1, Theta2, X_test, y_test, threshold);

[test_accuracy, precision, recall, F_score] = errorAnalysis(test_pred, y_test);

fprintf('\nTest Set Accuracy: %f\n', test_accuracy * 100);
fprintf('\nTest Set precision: %f\n', precision * 100);
fprintf('\nTest Set recall: %f\n', recall * 100);
fprintf('\nTest Set F_score: %f\n', F_score * 100);
