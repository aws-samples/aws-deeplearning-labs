# Sample scripts for AWS Blogpost: High performance ML models using PyTorch 2.0 on AWS - Part1

we adapted the training and inference scripts from the [TimeLMS repository](https://github.com/cardiffnlp/timelms) and added SageMaker related scripts.

TimeLMs is released without any restrictions, but our scoring code is based on the https://github.com/awslabs/mlm-scoring repository, which is distributed under Apache License 2.0. We also refer users to Twitter regulations regarding use of our models and test sets.

* Dateset: https://huggingface.co/datasets/tweet_eval
* Hugging Face Model Card: https://huggingface.co/cardiffnlp/twitter-roberta-base-sentiment-latest 
* Copy of [mlm-scoring](https://github.com/awslabs/mlm-scoring) [Apache License 2.0](./LICENSE.txt)
* Original [TweetEval paper](https://arxiv.org/pdf/2010.12421.pdf).
```
@inproceedings{barbieri2020tweeteval,
  title={{TweetEval:Unified Benchmark and Comparative Evaluation for Tweet Classification}},
  author={Barbieri, Francesco and Camacho-Collados, Jose and Espinosa-Anke, Luis and Neves, Leonardo},
  booktitle={Proceedings of Findings of EMNLP},
  year={2020}
}
```
