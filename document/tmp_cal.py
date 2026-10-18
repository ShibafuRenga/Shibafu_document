minTime = 0.4 # 假设没有延迟


def cal_stot_to_stop(unit, runV, runBackV1, backDistance, runBackV2):

    slow_to_stop = unit / runV

    back1 = backDistance / runBackV1

    back2Time = backDistance / runBackV2

    totalStopTime = slow_to_stop + back1 + back2Time
    return totalStopTime


totalStopTime = cal_stot_to_stop(298 / 598, 10, 10, 0.15, 0.8)
stop4Time = cal_stot_to_stop(298 / 298, 12, 10, 0.05, 1)

print(stop4Time)
print(totalStopTime * 3 + minTime)