__author__='Jake Burkhead'
__email__='jlburkhead@ucdavis.edu'
__date__='31-07-2013'

from sklearn import linear_model
import numpy as np
import pandas as pd
import random

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


def main(train='/vol/data/kaggle/abc/train.csv', test='/vol/data/kaggle/abc/test.csv', questions='/vol/data/kaggle/abc/questions.csv', submit='/vol/data/kaggle/abc/submissions/logit.csv'):

    print "Reading data"
    
    train_data = load_data(train)
    test_data = load_data(test)
    questions = pd.read_csv(questions)

    print "Finished reading data"
    
    outdata = np.zeros(len(questions.index))
    for i in questions.index:
        print "Working on question " + str(i)
        model = linear_model.LogisticRegression()
        device_index = train_data['Device'] == questions['QuizDevice'][i]
        X_device = train_data[['X', 'Y', 'Z']][device_index]
        X_other = train_data[['X', 'Y', 'Z']][~device_index]
        rows = random.sample(X_other.index, len(X_device.index))
        X = X_device.append(X_other.iloc[rows])
        y = [1]*len(rows)
        y.extend([0]*len(rows))
        model.fit(X, y)
        preds = model.predict_proba(test_data[['X', 'Y', 'Z']][test_data['SequenceId'] == questions['SequenceId'][i]])[:,1]
        outdata[i] = preds.mean()

    write_submission(submit, outdata)


if __name__ == "__main__":
    args = {'train': '/vol/data/kaggle/abc/train.csv',
            'test': '/vol/data/kaggle/abc/test.csv',
            'questions': '/vol/data/kaggle/abc/questions.csv',
            'submit': '/vol/data/kaggle/abc/submissions/logit.csv'}
    main(**args)
