from transformers import pipeline
model_path="/workspace/aws-deeplearning-labs/workshop/twitter_lm/scripts/saved_model/"
sentiment_task = pipeline("sentiment-analysis", model=model_path, tokenizer=model_path)
print(sentiment_task("Covid cases are increasing fast!"))

