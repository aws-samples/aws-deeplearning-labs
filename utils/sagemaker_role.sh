# Create SageMaker Execution role

cat << EoF > trust.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EoF

aws iam create-role --role-name sagemakerrole --assume-role-policy-document file://trust.json --output=text
aws iam attach-role-policy --role-name sagemakerrole --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name sagemakerrole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess