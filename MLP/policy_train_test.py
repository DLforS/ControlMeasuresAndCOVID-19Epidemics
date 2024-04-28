import pandas as pd
import numpy as np
import torch
from torch.utils.data import DataLoader,TensorDataset
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from torch.optim.lr_scheduler import StepLR

mm = MinMaxScaler()
all_features = np.loadtxt('country.txt')
all_labels = np.loadtxt('parameters.txt')
all_labels = mm.fit_transform(all_labels)#(127, 10)
all_index = np.array(range(0,127,1)).reshape(-1,1)

data = np.hstack((all_features, all_labels))
data = np.hstack((data, all_index))
"""
[ 26. 111.  81.  55.  44.  96.  80. 125. 114.  62.  45.   4.  18.  95.
  36.  94.  19. 120.  10.  40.  11.  98. 104.  77.   0.  78.]
"""
train_set, test_set = train_test_split(data[:, :], test_size=0.2, random_state=42)# 101 26
print(test_set)
input(">>>")
np.savetxt('ys_true_train1.txt', mm.inverse_transform(train_set[:, 16:26]))
np.savetxt('ys_true_test1.txt', mm.inverse_transform(test_set[:, 16:26]))
print()
#print(test_set[:, -1]+1)
#input(">>> ")
train_set = train_set.astype(np.float32)#(1314, 331)
test_set = test_set.astype(np.float32)
train_features = train_set[:, 0:16]#(101, 16)
train_labels = train_set[:, 16:26]#(101, 11)

test_features = test_set[:, 0:16]# (26, 16)
test_labels = test_set[:, 16:26]

train_features = torch.from_numpy(train_features).cuda()
train_labels = torch.from_numpy(train_labels).cuda() # torch.Size([1314, 1])
train_set = TensorDataset(train_features, train_labels)
train_data = DataLoader(dataset=train_set, batch_size=10, shuffle=True)

test_features = torch.from_numpy(test_features).cuda()
test_labels = torch.from_numpy(test_labels).cuda() # torch.Size([1314, 1])
test_set = TensorDataset(test_features, test_labels)
test_data = DataLoader(dataset=test_set, batch_size=10, shuffle=False)


#构建网络结构
class Net(torch.nn.Module):# 继承 torch 的 Module
    def __init__(self, n_feature, n_output):
        super(Net, self).__init__()     # 继承 __init__ 功能
        # 定义每层用什么样的形式
        self.layer1 = torch.nn.Linear(n_feature, 100).cuda()   #
        #self.layer2 = torch.nn.Linear(600, 1200).cuda()   #
        self.layer3 = torch.nn.Linear(100, n_output).cuda()
        self.dropout = torch.nn.Dropout(0.9)

    def forward(self, x):
        #x torch.Size([10, 16])
        # https://blog.csdn.net/qsmx666/article/details/104673409
        x = self.layer1(x)#torch.Size([10, 100])
        x = self.dropout(x)
        x = torch.relu(x)#torch.Size([10, 100])
        x = self.layer3(x)#torch.Size([10, 10])
        x = torch.sigmoid(x)#torch.Size([10, 10])
        return x

net = Net(16, 10)

optimizer = torch.optim.Adam(net.parameters(), lr=1e-3)

# 每跑800个step就把学习率乘以0.9
scheduler = StepLR(optimizer, step_size=800, gamma=0.9)
criterion =	torch.nn.MSELoss()

#记录用于绘图
losses = []#记录每次迭代后训练的loss
eval_losses = []#测试的

for i in range(10000):
    train_loss = 0
    # train_acc = 0
    net.train() #网络设置为训练模式 暂时可加可不加
    for tdata,tlabel in train_data:
        #前向传播
        y_ = net(tdata)
        #记录单批次一次batch的loss
        loss = criterion(y_, tlabel)
        '''
        更改loss
        '''
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
        #反向传播
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        scheduler.step()
        #累计单批次误差
        train_loss = train_loss + loss.item()

    losses.append(train_loss / len(train_data))
    np.savetxt('train_loss1.txt', losses)
    # 测试集进行测试
    eval_loss = 0
    net.eval()  # 可加可不加
    for edata, elabel in test_data:
        # 前向传播
        y_ = net(edata)
        loss = criterion(y_, elabel)
        eval_loss = eval_loss + loss.item()
    eval_losses.append(eval_loss / len(test_data))
    np.savetxt('test_loss1.txt', eval_losses)
    if i % 100 == 0:
        print('epoch: {}, trainloss: {}, evalloss: {}'.format(i, train_loss / len(train_data), eval_loss / len(test_data)))


ys_prediction_train = net(train_features) # torch.Size([127, 10])
ys_pre_train = mm.inverse_transform(ys_prediction_train.data.cpu().numpy())
ys_prediction_test = net(test_features) # torch.Size([127, 10])
ys_pre_test = mm.inverse_transform(ys_prediction_test.data.cpu().numpy())#(26, 10)

np.savetxt('ys_pre_train1.txt', ys_pre_train)
np.savetxt('ys_pre_test1.txt', ys_pre_test)
fig = plt.figure(figsize=(12, 4), facecolor='white')
ax_traj = fig.add_subplot(231, frameon=False)
ax_phase = fig.add_subplot(232, frameon=False)
ax_vecfield = fig.add_subplot(233, frameon=False)
ax_traj1 = fig.add_subplot(234, frameon=False)
ax_phase1 = fig.add_subplot(235, frameon=False)
ax_vecfield1 = fig.add_subplot(236, frameon=False)

#plt.title("curve")
xx = list(i for i in range(len(train_labels[:, 0].data.cpu().numpy())))
#plt.plot(xx, train_labels[:, 0].data.cpu().numpy())
#plt.plot(xx, ys_pre[:, 0].data.cpu().numpy())
ax_traj.set_title('Trajectories')
ax_traj.set_xlabel('t')
ax_traj.set_ylabel('x, y')
ax_traj.plot(xx, train_labels[:, 0].data.cpu().numpy(), 'o-')
ax_traj.plot(xx, ys_pre_train[:, 0], '*-')
ax_phase.plot(xx, train_labels[:, 1].data.cpu().numpy(), 'o-')
ax_phase.plot(xx, ys_pre_train[:, 1], '*-')
ax_vecfield.plot(xx, train_labels[:, 2].data.cpu().numpy(), 'o-')
ax_vecfield.plot(xx, ys_pre_train[:, 2], '*-')
xxx = list(i for i in range(len(test_labels[:, 0].data.cpu().numpy())))
ax_traj1.plot(xxx, test_labels[:, 0].data.cpu().numpy(), 'o-')
ax_traj1.plot(xxx, ys_pre_test[:, 0], '*-')
ax_phase1.plot(xxx, test_labels[:, 1].data.cpu().numpy(), 'o-')
ax_phase1.plot(xxx, ys_pre_test[:, 1], '*-')
ax_vecfield1.plot(xxx, test_labels[:, 2].data.cpu().numpy(), 'o-')
ax_vecfield1.plot(xxx, ys_pre_test[:, 2], '*-')
#ax_traj.legend()
#plt.legend("ys", "ys_pre")
plt.show()


