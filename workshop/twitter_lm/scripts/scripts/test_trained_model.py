from transformers import pipeline
model_path="/workspace/timelms/scripts/saved_model/"
sentiment_task = pipeline("sentiment-analysis", model=model_path, tokenizer=model_path)
print(sentiment_task("Covid cases are increasing fast!"))

