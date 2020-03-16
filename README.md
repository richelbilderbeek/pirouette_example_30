# pirouette_example_30

Branch   |[![Travis CI logo](pics/TravisCI.png)](https://travis-ci.org)                                                                                                 |[![AppVeyor logo](pics/AppVeyor.png)](https://appveyor.com)                                                                                               
---------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------
`master` |[![Build Status](https://travis-ci.org/richelbilderbeek/pirouette_example_30.svg?branch=master)](https://travis-ci.org/richelbilderbeek/pirouette_example_30) |[![Build status](https://ci.appveyor.com/api/projects/status/xgnu863auclyqfs5/branch/master?svg=true)](https://ci.appveyor.com/project/richelbilderbeek/pirouette-example-30/branch/master)
`develop`|[![Build Status](https://travis-ci.org/richelbilderbeek/pirouette_example_30.svg?branch=develop)](https://travis-ci.org/richelbilderbeek/pirouette_example_30)|[![Build status](https://ci.appveyor.com/api/projects/status/xgnu863auclyqfs5/branch/develop?svg=true)](https://ci.appveyor.com/project/richelbilderbeek/pirouette-example-30/branch/develop)

A [pirouette example](https://github.com/richelbilderbeek/pirouette_examples):
use one exemplary DD tree, as used in the pirouette article.

## Running on Peregrine

Install `pirouette` using the [peregrine](https://github.com/richelbilderbeek/peregrine)
bash and R scripts.

Then, in the main folder of this repo, type:

```
sbatch scripts/rerun.sh
```

## Related settings

 * [Multiple DD trees](https://github.com/richelbilderbeek/pirouette_example_28)

## Results

The exemplary true tree:

![](example_30_314/true_tree.png)

The resulting error distributions:

![](example_30_314/errors.png)
