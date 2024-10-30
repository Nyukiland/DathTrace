using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PathSystem : MonoBehaviour
{
	[SerializeField]
	private List<Transform> _controlPoints = new();

	[SerializeField, Min(1)]
	private int _resolution;

	List<PathStorage> _pathPoint = new();

	private void Update()
	{
		EditorUpdate();
	}

	void GeneratePath()
	{
		if (_controlPoints.Count < 2) return;

		_pathPoint.Clear();

		for (int i = 0; i < _controlPoints.Count; i++)
		{
			List<PathStorage> tempList = new();

			PathStorage temp = new();
			temp.pos = _controlPoints[i].position;
			temp.rot = _controlPoints[i].eulerAngles;
			temp.size = _controlPoints[i].localScale.x;

			tempList.Add(temp);

			temp.pos = _controlPoints[i].position + _controlPoints[i].forward * _controlPoints[i].localScale.z;

			tempList.Add(temp);

			if (_resolution > 1)
			{
				for (int j = 0; j < _resolution; j++)
				{
					List<PathStorage> newTempList = new();

					for (int k = 0; k < tempList.Count; k++)
					{
						if (k + 1 >= tempList.Count)
						{
							Vector3.Distance(tempList[k].pos, _controlPoints[i + 1].position);
						}
						else
						{
							Vector3.Distance(tempList[k].pos, tempList[k+1].pos);
						}
					}
				}
			}

			foreach (PathStorage t in tempList)
			{
				_pathPoint.Add(temp);
			}
		}
	}

	#region Editor

	private List<TransformStorage> _previousPoints = new();

	private void OnValidate()
	{
		GeneratePath();
	}

	void EditorUpdate()
	{
#if UNITY_EDITOR
		if (Application.isPlaying) return;

		if (!IsSimilar(_controlPoints, _previousPoints) || _pathPoint.Count == 0) GeneratePath();

#endif
	}

	private bool IsSimilar(List<Transform> current, List<TransformStorage> previous)
	{
		bool isSame = true;

		for (int i = 0; i < current.Count; i++)
		{
			if (previous.Count - 1 < i)
			{
				isSame = false;

				TransformStorage t = new();
				t.position = current[i].position;
				t.eulerAngle = current[i].eulerAngles;
				t.localScale = current[i].localScale;
				previous.Add(t);

				continue;
			}

			if (current[i].position != previous[i].position || current[i].eulerAngles != previous[i].eulerAngle || current[i].localScale != previous[i].localScale)
			{
				isSame = false;

				TransformStorage temp = new();

				temp.position = current[i].position;
				temp.eulerAngle = current[i].eulerAngles;
				temp.localScale = current[i].localScale;

				previous[i] = temp;
			}
		}

		return isSame;
	}

	private void OnDrawGizmos()
	{
		foreach (Transform t in _controlPoints)
		{
			Gizmos.color = Color.black;
			Gizmos.DrawRay(t.position, t.transform.right * t.localScale.x);
			Gizmos.DrawRay(t.position, -t.transform.right * t.localScale.x);

			Gizmos.color = Color.blue;
			Gizmos.DrawRay(t.position, t.transform.forward * t.localScale.z);
		}

		Gizmos.color = Color.white;
		for (int i = 0; i < _pathPoint.Count; i++)
		{
			if (i + 1 >= _pathPoint.Count) Gizmos.DrawLine(_pathPoint[i].pos, _pathPoint[0].pos);
			else Gizmos.DrawLine(_pathPoint[i].pos, _pathPoint[i + 1].pos);
		}
	}

	public struct TransformStorage
	{
		public Vector3 position;
		public Vector3 eulerAngle;
		public Vector3 localScale;
	}
	#endregion

	public struct PathStorage
	{
		public Vector3 pos;
		public Vector3 rot;
		public float size;
	}
}
