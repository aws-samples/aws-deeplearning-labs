from kubeflow.training import TrainingClient
from kubeflow.training.constants import constants

def save_master_worker_spec(pytorch_client: TrainingClient, pytorch_jobname: str) -> str:
    """save_master_worker_spec saves master and worker spec to a pipeline_yaml_specifications folder. """
    import yaml
    import os

    if pytorch_client is None:
        print("Please pass a valid pytorch client")
    if (not len(pytorch_jobname) or pytorch_jobname is None):
        print("Please pass a valid job name")
       
    pytorchjob=pytorch_client.get_pytorchjob(pytorch_jobname)
    
    master_spec=pytorchjob.spec.pytorch_replica_specs['Master']
    worker_spec=pytorchjob.spec.pytorch_replica_specs['Worker']
    
    if not os.path.exists("pipeline_yaml_specifications"):
        os.makedirs("pipeline_yaml_specifications")

    with open('pipeline_yaml_specifications/pipeline_master_spec.yml', 'w') as yaml_outfile_file:
        yaml.dump(master_spec, yaml_outfile_file, default_flow_style=False)
    
    with open('pipeline_yaml_specifications/pipeline_worker_spec.yml', 'w') as yaml_outfile_file:
        yaml.dump(worker_spec, yaml_outfile_file, default_flow_style=False)
        
    return "specs saved in ./pipeline_yaml_specifications folder" 
    
def read_logs(pytorch_client: TrainingClient, jobname: str, namespace: str, log_type: str) -> None:
    """read_logs helps get logs from master and worker pods of distributed training using PyTorch Training Operators.
    log_type: all, worker:all, master:all, worker:0, worker:1
    """
    import time
    
    print("Waiting for Pod condition to be Running")

    pytorch_client.wait_for_job_conditions(
        jobname, 
        expected_conditions=set(["Running"]), 
        job_kind=constants.PYTORCHJOB_KIND, 
        namespace=namespace
    )
    
    print("Master and Worker Pods are Running now")

    print("**** PyTorchJob status **** ")
    print(pytorch_client.get_job_conditions(jobname, namespace, job_kind=constants.PYTORCHJOB_KIND))
    print("*************************** \n")
    
    print("\n**** Pod names of the PyTorchJob **** ")
    print(pytorch_client.get_job_pod_names(jobname, namespace))
    print("*************************** \n")
    
    if pytorch_client is None:
        print("Please pass a valid pytorch client")
    if (not len(jobname) or jobname is None):
        print("Please pass a valid job name")
    if (not len(namespace) or namespace is None):
        print("Please pass a valid namespace")
    if (not len(log_type) or (log_type is None) or (":" not in log_type and "all" not in log_type)):
        print("Please pass a valid log_type name which is not empty and has ':'. e.g all, worker:all, master:all, worker:0, worker:1")
        
    log_type_list=log_type.split(":")
    
    if log_type_list[0] in ['worker','master']:
        if log_type_list[1] == 'all':
            pytorch_client.get_job_logs(
                jobname,
                namespace=namespace,
                replica_type=log_type_list[0],
                container=constants.PYTORCHJOB_CONTAINER,
                is_master=False,
                follow=True
            )
        else:
            pytorch_client.get_job_logs(
                jobname,
                namespace=namespace,
                replica_type=log_type_list[0],
                replica_index=log_type_list[1],
                container=constants.PYTORCHJOB_CONTAINER,
                is_master=False,
                follow=False
            )
    else: 
        pytorch_client.get_job_logs(
            jobname, 
            namespace=namespace, 
            container=constants.PYTORCHJOB_CONTAINER,
            is_master=False, 
            follow=False
        )