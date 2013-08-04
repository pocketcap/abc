using DataFrames
using Resampling
using GLM

data_dir = "/vol/data/kaggle/abc/"

train = readtable(string(data_dir, "train.csv"))
test = readtable(string(data_dir, "test.csv"))
questions = readtable(string(data_dir, "questions.csv"))

outdata = []
for i =  [1:10]#[1:nrow(questions)]
    println(@sprintf("Working on question %s", i))
    this_question = questions[i,:]
    this_device = this_question[1,"QuizDevice"]
    this_sequence = this_question[1, "SequenceId"]
    
    X_device = train[train["Device"] .== this_device,:]
    X_other = train[train["Device"] .!= this_device,:]
    X_other = resample(X_other, nrow(X_device))
    train_X = rbind(X_device, X_other)
    train_X["y"] = int(train_X["Device"] .== this_device)
    
    mod = glm(:(y ~ X + Y + Z), train_X, Binomial())

    this_test = matrix(test[test["SequenceId"] .== this_sequence,["X", "Y", "Z"]])
    this_test = hcat(ones(size(this_test, 1), 1), this_test)

    z = this_test * coef(mod)
    
    outdata = [outdata, mean(1 / (1 + exp(-z)))]

end

    
