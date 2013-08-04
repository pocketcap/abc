__author__='Jake Burkhead'
__email__='jlburkhead@ucdavis.edu'
__date__='31-07-2013'

from sklearn import linear_model
import numpy as np
import pandas as pd
import random
import sys

def load_data(filename, chunksize=500000, iterator=True):
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
    sys.stdout.flush()

    train_data = load_data(train)
    train_data = np.array(train_data)
    test_data = load_data(test)
    test_data = np.array(test_data)
    questions = pd.read_csv(questions)

    print "Finished reading data"
    sys.stdout.flush()

    outdata = np.zeros(len(questions.index))
    for i in questions.index:
        print "Working on question " + str(i+1)
        sys.stdout.flush()
        model = linear_model.LogisticRegression()
        device_index = train_data[:,0] == questions['QuizDevice'][i]
        X_device = train_data[device_index, 2:5]
        X_other = train_data[np.invert(device_index), 2:5]
        rows = random.sample(range(X_other.shape[0]), X_device.shape[0])
        X = np.vstack((X_device, X_other[rows,:]))
        y = [1]*len(rows)
        y.extend([0]*len(rows))
        model.fit(X, y)
        preds = model.predict_proba(test_data[test_data[:,0] == questions['SequenceId'][i], 2:5])[:,1]
        outdata[i] = preds.mean()

    write_submission(submit, outdata)


if __name__ == "__main__":
    args = {'train': '/vol/data/kaggle/abc/train.csv',
            'test': '/vol/data/kaggle/abc/test.csv',
            'questions': '/vol/data/kaggle/abc/questions.csv',
            'submit': '/vol/data/kaggle/abc/submissions/logit.csv'}
    main(**args)
