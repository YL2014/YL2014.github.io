---
title: mongoose分组查询记录
date: 2018-11-01 15:35:31
tags:  
    - mongoose
---

mongoose聚合分组(aggregate, group)的简单使用记录，直接上代码

<!-- more -->

#### 数据模型
```javascript
# model/report.js

module.exports = ({ Schema, db }, app) => {
  const Report = new Schema({
    platform: String,
    cname: String,
    url: String,
    floor: String
  }, {
    timestamps: true
  })
  return db.model('Report', Report, 'Report')
}
```

#### 以某个字段分组分组

- aggregate group使用：如果需要分组的字段为`cname`，那么`_id`对应的值就为`$cname`

```javascript
const dataByDate = await this.model('report').aggregate([
  { $match: queryCondition },
  { $group: {
    _id: '$cname',
    count: { $sum: 1 }
  } }
])
```

- 输出结果

```javascript
[
    {
        "_id": "title2",
        "count": 22
    },
    {
        "_id": "title3",
        "count": 8
    },
    {
        "_id": "title4",
        "count": 10
    }
]
```

#### 多个维度

上面是通过字段`cname`来分组，如果我们同时想统计每天的每个`cname`的数量呢？如下，`_id`里指定两个分组条件，然后使用`$project`给分组后数据字段重命名，然后继续分组

```javascript
const data = await this.model('report').aggregate([
  {
    $match: queryCondition
  }, { $group: {
    _id: {
      [dimension]: '$' + dimension,
      date: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }
    },
    count: { $sum: 1 }
  } }, {
    $project: {
      _id: 0,
      date: '$_id.date',
      [dimension]: {
        [dimension]: `$_id.${dimension}`,
        count: '$count'
      }
    }
  }, {
    $group: {
      _id: '$date',
      [dimension]: { $push: `$${dimension}` }
    }
  }
])
```

输出

```javascript
[
    {
        "_id": "2018-10-30",
        "cname": [
            {
                "cname": "title4",
                "count": 2
            }
        ]
    },
    {
        "_id": "2018-10-31",
        "cname": [
            {
                "cname": "title4",
                "count": 8
            },
            {
                "cname": "title3",
                "count": 8
            },
            {
                "cname": "title2",
                "count": 22
            }
        ]
    }
]
```

更多用法，参考[官方文档](https://mongoosejs.com/docs/api.html#Aggregate)

#### 参考
- [https://docs.mongodb.com/manual/aggregation/](https://docs.mongodb.com/manual/aggregation/)
- [https://mongoosejs.com/docs/api.html#Aggregate](https://mongoosejs.com/docs/api.html#Aggregate)

