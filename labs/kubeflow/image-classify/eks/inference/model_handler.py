from torchvision import transforms
from ts.torch_handler.image_classifier import ImageClassifier
from torch.profiler import ProfilerActivity
import base64


class CIFARImageClassifier(ImageClassifier):
    
    image_processing = transforms.Compose([
        transforms.RandomCrop(32, padding=4),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize((0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)),
    ])

    def __init__(self):
        super(CIFARImageClassifier, self).__init__()
        self.profiler_args = {
            "activities" : [ProfilerActivity.CPU],
            "record_shapes": True,
        }

    def preprocess(self, data):
        # Base64 encode the image to avoid the framework throwing
        # non json encodable errors
        print("printing")
        print(data)
        
        b64_data = []
        for row in data:
            print("printing row data")
            print(row)
            #input_data = row.get("image_bytes")("b64") or row.get("body")
            input_data = row["data"]
            # Wrap the input data into a format that is expected by the parent
            # preprocessing method
            b64_data.append({"body": base64.b64decode(input_data)})
        return ImageClassifier.preprocess(self, b64_data)
    
    
    def postprocess(self, data):
        """The post process of MNIST converts the predicted output response to a label.
        Args:
            data (list): The predicted output from the Inference with probabilities is passed
            to the post-process function
        Returns:
            list : A list of dictionaries with predictions and explanations is returned
        """
        return data.argmax(1).tolist()
