function pascal_person_grammar(dotrainval, testyear)

% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------

% Set configuration override
global VOC_CONFIG_OVERRIDE;
if isempty(VOC_CONFIG_OVERRIDE)
  VOC_CONFIG_OVERRIDE = @voc_config_person_grammar;
end

cls = 'person';
conf = voc_config();
cachedir = conf.paths.model_dir;
testset = conf.eval.test_set;

if nargin < 1
  dotrainval = false;
end

if nargin < 2
  % which year to test on -- a string, e.g., '2007'.
  testyear = conf.pascal.year;
end

timestamp = datestr(datevec(now()), 'dd.mmm.yyyy:HH.MM.SS');

% set the note to the training time if none is given
if nargin < 3
  note = timestamp;
end

% record a log of the training and test procedure
diary(conf.training.log([cls '-' timestamp]));

th = tic;
model = pascal_train_person_grammar(note);
toc(th);
% Free feature vector cache memory
fv_cache('free');

% lower threshold to get high recall
model.thresh = min(conf.eval.max_thresh, model.thresh);
model.interval = conf.eval.interval;

ds = pascal_test(model, testset, testyear, testyear);
ap1 = pascal_eval(cls, ds, testset, testyear, testyear);
%[ap1, ap2] = bboxpred_rescore(cls, testset, testyear);

fprintf('AP = %.4f (without bounding box prediction)\n', ap1)
%fprintf('AP = %.4f (with bounding box prediction)\n', ap2)

% Compute detections on the trainval dataset (used for context rescoring)
if dotrainval
  trainval(cls);
end

% Clear the override
clearvars -global VOC_CONFIG_OVERRIDE;
