% use the surrounding pixels to predict the whether a pixel is part of 
% a mitochondrion

%% Initialization
clear ; close all; clc

%% Set up the parameters and constants

% input information
border = 10;
input_width = 2 * border + 1;

% parameters for training 
lambda = 2;
max_runs = 200;

% threshold for predicting whether a pixel is part of a mitochondrion
threshold = 0.5;

% neural network structure
hidden_layer1_size = 25;  
output_layer_size = 1;

%% Load Data 

fprintf('\nLoading Data ...\n')

loadinputs;


%% ================  Initializing Pameters ================
%  In this part of the exercise, you will be starting to implment a two
%  layer neural network that classifies digits. You will start by
%  implementing a function to initialize the weights of the neural network
%  (randInitializeWeights.m)
% 
% fprintf('\nInitializing Neural Network Parameters ...\n')
% 
% initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer1_size);
% initial_Theta2 = randInitializeWeights(hidden_layer1_size, output_layer_size);
% 
% 
% % Unroll parameters
% initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];



%% =============== Gradient checking ===============
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

%% ===================  Training NN ===================
%  You have now implemented all the code necessary to train a neural 
%  network. To train your neural network, we will now use "fmincg", which
%  is a function which works similarly to "fminunc". Recall that these
%  advanced optimizers are able to train our cost functions efficiently as
%  long as we provide them with the gradient computations.
% %
% fprintf('\nTraining Neural Network... \n');
% 
% %  After you have completed the assignment, change the MaxIter to a larger
% %  value to see how more training helps.
% options = optimset('MaxIter', max_runs);
% 
% %  You should also try different values of lambda
% % lambda = 3;
% 
% % Create "short hand" for the cost function to be minimized
% costFunction = @(p) nnCostFunction_MA(p, ...
%                                    input_layer_size, ...
%                                    hidden_layer1_size, ...
%                                    output_layer_size, X_training, y_training, lambda);
% 
% % Now, costFunction is a function that takes in only one argument (the
% % neural network parameters)
% [nn_params, cost] = fmincg(costFunction, initial_nn_params, options);
% 
% 
% % Obtain Theta1, Theta2 back from nn_params
% Theta1_size = hidden_layer1_size * (input_layer_size + 1);
% 
% Theta1 = reshape(nn_params(1:Theta1_size), ...
%                  hidden_layer1_size, (input_layer_size + 1));
%              
% Theta2 = reshape(nn_params((1 + Theta1_size): end), ...
%                  output_layer_size, (hidden_layer1_size + 1));
% 
% fprintf('Program paused. Press enter to continue.\n');
% % pause;

%% Choose the number of principle component (K)

fprintf('\nChoosing k  ... \n');

% mean normalisation
[X_norm, mu, sigma] = featureNormalize(double(X_training));

% run pca 
[U, S] = pca(X_norm);

% number of features
n = size(X_training, 2);

% pick the smallest k that retains 99% of variance in the original set
for K = 1 : n
    variance_retained = sum(diag(S(1:K, 1:K))) / sum(diag(S));
    if (variance_retained >= 0.99)
        break;
    end
end

% report the K found
fprintf('the smallest k found: %d\n', K);
input_layer_size  = K;


%% training set dimension reduction 

fprintf('\nDimension reduction  ... \n');

% Project the data onto the lower dimension
Z_training = projectData(X_norm, U, K);

X_training = Z_training;


%% test set dimension reduction

% mean normalisation
[X_norm, mu, sigma] = featureNormalize(double(X_test));

% run pca 
[U, S] = pca(X_norm);

% Project the data onto lower dimension, can change K later
Z_test = projectData(X_norm, U, K);

X_test = Z_test;


%% =================== Plot Learning Curve ===================
fprintf('\npreparing data for learning curve... \n');

training_size = size(X_training, 1);
test_size = size(X_test, 1);

options = optimset('MaxIter', max_runs);


% Create "short hand" for the cost function to be minimized
costFunction = @(p) nnCostFunction_MA(p, ...
                                   input_layer_size, ...
                                   hidden_layer1_size, ...
                                   output_layer_size, X_training, y_training, lambda);

f_score_train = zeros(training_size, 1);

f_score_test = zeros(training_size, 1);

accuracy_train = zeros(training_size, 1);

accuracy_test = zeros(training_size, 1);

for i = 1 : training_size
    X_training_i = X_training(1:i, :);
    y_training_i = y_training(1:i);
    
    initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer1_size);
    initial_Theta2 = randInitializeWeights(hidden_layer1_size, output_layer_size);


    initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];    

    [nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

    % Obtain Theta1, Theta2 back from nn_params
    Theta1_size = hidden_layer1_size * (input_layer_size + 1);

    Theta1 = reshape(nn_params(1:Theta1_size), ...
                     hidden_layer1_size, (input_layer_size + 1));

    Theta2 = reshape(nn_params((1 + Theta1_size): end), ...
                     output_layer_size, (hidden_layer1_size + 1));
    
    % training set
    training_pred_i = predict_MA(Theta1, Theta2, X_training_i, threshold);
    
    training_pred_i = (training_pred_i >= threshold);
    
    [train_accuracy_i, train_precision_i, train_recall_i, train_F_score_i] = errorAnalysis(training_pred_i, y_training_i);  
    
    f_score_train(i) = train_F_score_i;
    
    accuracy_train(i) = train_accuracy_i;
    
    
    % test set
    
    test_pred_i = predict_MA(Theta1, Theta2, X_test, threshold);
    
    test_pred_i = (test_pred_i >= threshold);
    
    [test_accuracy_i, test_precision_i, test_recall_i, test_F_score_i] = errorAnalysis(test_pred_i, y_test);  
    
    f_score_test(i) = test_F_score_i;
    
    accuracy_test(i) = test_accuracy_i;
    
    
end

% plot 
figure;
plot(1:training_size, f_score_train, 1:training_size, f_score_test);
title('Learning curve');
legend('Train', 'Test');
xlabel('Number of training examples');
ylabel('f_score');



% y start at 0
ylim([0 inf]);

%% ================= Part 4: results =================
%  After training the neural network, we would like to use it to predict
%  the labels. You will now implement the "predict" function to use the
%  neural network to predict the labels of the training set. This lets
%  you compute the training set accuracy.
% 
% % predict 
% fprintf('\npredict training dataset: \n');
% training_pred = predict_MA(Theta1, Theta2, X_training, threshold);
% compare_result(training_pred, y_training, threshold);
% 
% fprintf('\npredict new dataset: \n');
% test_pred = predict_MA(Theta1, Theta2, X_test, threshold);
% compare_result(test_pred, y_test, threshold);
% 
% % analysis
% training_pred = (training_pred >= threshold);
% test_pred = (test_pred >= threshold);
% [training_accuracy, training_precision, training_recall, training_F_score] = errorAnalysis(training_pred, y_training);
% [test_accuracy, test_precision, test_recall, test_F_score] = errorAnalysis(test_pred, y_test);
% 
% % dispay results
% fprintf('\nTraining, test set accuracy, precision, recall, F_score: \n');
% fprintf('%f\n', training_accuracy * 100);
% fprintf('%f\n', training_precision * 100);
% fprintf('%f\n', training_recall * 100);
% fprintf('%f\n', training_F_score * 100);
% fprintf('\n');
% fprintf('%f\n', test_accuracy * 100);
% fprintf('%f\n', test_precision * 100);
% fprintf('%f\n', test_recall * 100);
% fprintf('%f\n', test_F_score * 100);


% %% ================= Part 5: predict whole image =================
% img_width = 50;
% img_height = 50;
% 
% 
% 
% test_img = imread('0.tif');
% % test_img = process(test_img);
% test_bin = imread('0_b.tif');
% 
% test_img = test_img(1 : 2 * padding + img_height, 1 : 2 * padding + img_width);
% test_bin = test_bin(1 : 2 * padding + img_height, 1 : 2 * padding + img_width);
% 
% n = 1;
% 
% % maybe need to randomise
% for i = padding + 1 : padding + img_width
%     for j = padding + 1 : padding + img_height
%         
%         input = test_img(j - padding : j + padding, i - padding : i + padding);
%         input = process(input);
% 
%         test_img_X(n, :) = input(:);
% 
%         n = n + 1;
%         
%     end
% end
%         
% test_img_pred = predict_MA(Theta1, Theta2, test_img_X, threshold);
% actual_img = test_bin(padding + 1 : padding + img_height, padding + 1 : padding + img_width);
% pred_img = reshape(test_img_pred, img_height, img_width);
% 
% [test_accuracy, test_precision, test_recall, test_F_score] = errorAnalysis(test_img_pred, actual_img(:));
% 
% fprintf('\n');
% fprintf('%f\n', test_accuracy * 100);
% fprintf('%f\n', test_precision * 100);
% fprintf('%f\n', test_recall * 100);
% % fprintf('%f\n', test_F_score * 100);
% 
% 
% figure;
% imshowpair(pred_img, actual_img, 'montage');




%  not equal amount of 1s and 0s in the training sample, will tend to
%  predict everything as 1


