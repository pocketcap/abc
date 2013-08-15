__author__='Jake Burkhead'
__email__='jlburkhead@ucdavis.edu'
__date__='31-07-2013'

from sklearn import linear_model
from sklearn import cross_validation
from sklearn import metrics
import numpy as np
import pandas as pd
import random
import sys

def load_data(filename, chunksize=100000, iterator=True):
    '''
    Read large csvs in chunks and return a DataFrame
    '''
    reader = pd.read_csv(filename, chunksize=chunksize, iterator=iterator)
    data = pd.DataFrame()
    for chunk in reader:
        data = data.append(chunk)
        
    return data

def write_submission(filename, prediction):
    content = ['QuestionId,IsTrue']
    for i, p in enumerate(prediction):
        content.append('%i, %f' %(i+1,p))
        
    f = open(filename, 'w')
    f.write('\n'.join(content))
    f.close()
    print "Saved"

def main(train='/vol/data/kaggle/abc/train.csv', test='/vol/data/kaggle/abc/test.csv', questions='/vol/data/kaggle/abc/questions.csv', submit='/vol/data/kaggle/abc/submissions/multi_logit.csv', minibatch_size = 50000):
    
    print "Reading data"
    sys.stdout.flush()
    
    train_data = load_data(train)
    train_X = train_data[['X', 'Y', 'Z']]
    train_y = train_data['Device']
    questions = pd.read_csv(questions)
    
    print "Finished reading data"
    sys.stdout.flush()
    
    X_train, X_test, y_train, y_test = cross_validation.train_test_split(train_X, train_y, test_size = 0.25)
    
    cl = np.unique(train_y)
    
    model = SGDClassifier(loss = "log")
    minibatches = divmod(X_train.shape[0], minibatch_size)[0]
    for i in range(minibatches):
        mb_x = X_train[(i*minibatch_size):((i+1)*minibatch_size)]
        mb_y = y_train[(i*minibatch_size):((i+1)*minibatch_size)]
        
        model.fit(mb_x, mb_y, classes = cl)
        preds = model.predict(X_test)
        
        auc = metrics.auc_score(y_test, preds)
        
        


    
