import numpy as np
import torch
import matplotlib
import matplotlib.pyplot as plt
from torch.utils.data import DataLoader,TensorDataset
from sklearn.preprocessing import MinMaxScaler


mm = MinMaxScaler()
all_features = np.loadtxt('country.txt')
#all_features = np.linspace(0.01, 50, 5000)
all_labels = np.loadtxt('parameters.txt')
#all_labels = np.loadtxt("F.txt")
print(all_features.shape)
print(all_labels.shape)
input(">>>")
all_labels = mm.fit_transform(all_labels)#(127, 10)

train_features = all_features.astype(np.float32)#(1314, 331)
train_labels = all_labels.astype(np.float32)


train_features = torch.from_numpy(train_features).cuda()
train_labels = torch.from_numpy(train_labels).cuda() # torch.Size([1314, 1])



train_set = TensorDataset(train_features,train_labels)

train_data = DataLoader(dataset=train_set, batch_size=10, shuffle=True)


class Net(torch.nn.Module):
    def __init__(self, n_feature, n_output):
        super(Net, self).__init__()
        self.layer1 = torch.nn.Linear(n_feature, 100).cuda()
        #self.layer2 = torch.nn.Linear(100, 100).cuda()
        self.layer3 = torch.nn.Linear(100, n_output).cuda()

    '''
    网络设置为：
    x = self.layer1(x)
    x = torch.relu(x)
    #x = self.layer2(x)
    #x = torch.relu(x)
    x = self.layer3(x)
    x = torch.sigmoid(x)  得到的输出值没有负数
    '''
    def forward(self, x):
        x = self.layer1(x)
        x = torch.relu(x)
        #x = self.layer2(x)
        #x = torch.relu(x)
        x = self.layer3(x)
        #x = torch.sigmoid(x)
        return x

def Draw():
    pass

if __name__ == '__main__':

    net = Net(16, 10)
    optimizer = torch.optim.Adam(net.parameters(), lr=1e-4)
    criterion =	torch.nn.MSELoss()
    losses = []

    for i in range(10000):
        train_loss = 0
        net.train()
        for tdata,tlabel in train_data:
            y_ = net(tdata)# torch.Size([batch_size, 10])
            loss = criterion(y_, tlabel)

            loss_0 = torch.mean(
                torch.where(y_[:, 0] < 0,
                            torch.abs(y_[:, 0]),
                            torch.full_like(y_[:, 0], 0))
            )
            loss_1 = torch.mean(
                torch.where(y_[:, 1] < 0,
                            torch.abs(y_[:, 1]),
                            torch.full_like(y_[:, 1], 0))
            )
            loss_2 = torch.mean(
                torch.where(y_[:, 2] < 0,
                            torch.abs(y_[:, 2]),
                            torch.full_like(y_[:, 2], 0))
            )
            loss_3 = torch.mean(
                torch.where(y_[:, 3] < 0,
                            torch.abs(y_[:, 3]),
                            torch.full_like(y_[:, 3], 0))
            )
            loss_4 = torch.mean(
                torch.where(y_[:, 4] < 0,
                            torch.abs(y_[:, 4]),
                            torch.full_like(y_[:, 4], 0))
            )
            loss_5 = torch.mean(
                torch.where(y_[:, 5] < 0,
                            torch.abs(y_[:, 5]),
                            torch.full_like(y_[:, 5], 0))
            )
            loss_6 = torch.mean(
                torch.where(y_[:, 6] < 0,
                            torch.abs(y_[:, 6]),
                            torch.full_like(y_[:, 6], 0))
            )
            loss_7 = torch.mean(
                torch.where(y_[:, 7] < 0,
                            torch.abs(y_[:, 7]),
                            torch.full_like(y_[:, 7], 0))
            )
            loss_8 = torch.mean(
                torch.where(y_[:, 8] < 0,
                            torch.abs(y_[:, 8]),
                            torch.full_like(y_[:, 8], 0))
            )
            loss_9 = torch.mean(
                torch.where(y_[:, 9] < 0,
                            torch.abs(y_[:, 9]),
                            torch.full_like(y_[:, 9], 0))
            )

            #loss = loss + loss_0 + loss_1 + loss_2 + loss_3 + loss_4 + loss_5 + loss_6 + loss_7 + loss_8 + loss_9
            #loss = torch.mean(torch.abs(y_ - tlabel))
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            train_loss = train_loss + loss.item()



        losses.append(train_loss / len(train_data))
        np.savetxt('loss.txt', losses)
        if i % 100 == 0:
            print('epoch: {}, trainloss: {}'.format(i, train_loss / len(train_data)))

    ys_prediction = net(train_features) # torch.Size([127, 10])
    ys_pre = mm.inverse_transform(ys_prediction.data.cpu().numpy())
    #tlabel = mm.inverse_transform(tlabel)
    np.savetxt('ys_pre.txt', ys_pre)
    fig = plt.figure(figsize=(12, 4), facecolor='white')
    ax_traj = fig.add_subplot(131, frameon=False)
    ax_phase = fig.add_subplot(132, frameon=False)
    ax_vecfield = fig.add_subplot(133, frameon=False)

    #plt.title("curve")
    xx = list(i for i in range(len(train_labels[:, 0].data.cpu().numpy())))
    #plt.plot(xx, train_labels[:, 0].data.cpu().numpy())
    #plt.plot(xx, ys_pre[:, 0].data.cpu().numpy())
    ax_traj.set_title('Trajectories')
    ax_traj.set_xlabel('t')
    ax_traj.set_ylabel('x, y')
    ax_traj.plot(xx, train_labels[:, 0].data.cpu().numpy(), 'o-')
    ax_traj.plot(xx, ys_pre[:, 0], '*-')
    ax_phase.plot(xx, train_labels[:, 1].data.cpu().numpy(), 'o-')
    ax_phase.plot(xx, ys_pre[:, 1], '*-')
    ax_vecfield.plot(xx, train_labels[:, 2].data.cpu().numpy(), 'o-')
    ax_vecfield.plot(xx, ys_pre[:, 2], '*-')
    #ax_traj.legend()
    #plt.legend("ys", "ys_pre")
    plt.show()






"""
        self.layer1 = torch.nn.Linear(n_feature, 100).cuda()
        self.layer2 = torch.nn.Linear(100, 100).cuda()
        self.layer3 = torch.nn.Linear(100, n_output).cuda()
"""