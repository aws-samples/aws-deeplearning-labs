from transformers import pipeline
model_path="models/twitter-roberta-base-sentiment-latest/"
sentiment_task = pipeline("sentiment-analysis", model=model_path, tokenizer=model_path)
print(sentiment_task("Covid cases are increasing fast!"))

