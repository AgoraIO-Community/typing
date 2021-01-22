package io.agora.typing.ui.chat

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.EditText
import android.widget.TextView
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.observe
import io.agora.typing.R
import io.agora.typing.base.Message
import io.agora.typing.base.MessageType
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.*


@ExperimentalCoroutinesApi
@FlowPreview
class ChatFragment(var friend: String) : Fragment() {

    companion object {
        fun newInstance(friend: String) = ChatFragment(friend)
    }

    private lateinit var messageBox: View
    private lateinit var viewModel: ChatModel
    private lateinit var inputMessage: EditText
    private lateinit var messageView: TextView
    private lateinit var onlineView: View

    private lateinit var animShake: Animation

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val root = inflater.inflate(R.layout.chat_fragment, container, false)
        messageBox = root.findViewById(R.id.frameLayout)
        inputMessage = root.findViewById(R.id.inputMessage)
        messageView = root.findViewById(R.id.message)
        onlineView = root.findViewById(R.id.online)
        return root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProvider(this).get(ChatModel::class.java)
        animShake = AnimationUtils.loadAnimation(context, R.anim.shake)

        messageBox.setOnClickListener {
            messageBox.startAnimation(animShake)
            viewModel.vibrate()
        }

        inputMessage.setHorizontallyScrolling(false)
        inputMessage.maxLines = Int.MAX_VALUE
        inputMessage.setOnEditorActionListener { _, _, _ ->
            inputMessage.text = null
            viewModel.sendMessage("")
            true
        }

        inputMessage.addTextChangedListener {
            viewModel.sendMessage(it.toString())
        }

        viewModel.onlineStatus(friend).observe(this) { result ->
            if (result.success) {
                result.data?.let {
                    onlineView.setBackgroundResource(if (it) R.drawable.online else R.drawable.offline)
                }
            } else {
                result.message?.let {
                    viewModel.snackBar.value = it
                }
            }
        }

        viewModel.receivedMessage(friend).observe(this) { result ->
            if (result.success) {
                val message = Message(result.data?.message?.text ?: "")
                when (message.type) {
                    MessageType.Vibrate -> vibrate()
                    MessageType.Text -> messageView.text = message.data
                }
            } else {
                result.message?.let {
                    viewModel.snackBar.value = it
                }
            }
        }

        viewModel.onInputMessage(friend).observe(this) { result ->
            if (!result.success) {
                result.message?.let {
                    viewModel.snackBar.value = it
                }
            }
        }

        viewModel.onVibrateMessage(friend).observe(this) { result ->
            if (!result.success) {
                result.message?.let {
                    viewModel.snackBar.value = it
                }
            }
        }

        // Show a snackbar whenever the [ViewModel.snackbar] is updated a non-null value
        viewModel.snackBar.observe(this) { text ->
            text?.let {
                this.view?.let { it1 -> Snackbar.make(it1, it, Snackbar.LENGTH_SHORT).show() }
                viewModel.onSnackbarShown()
            }
        }
    }

    private fun vibrate() {
        inputMessage.startAnimation(animShake)
        val vibrator = context?.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        if (Build.VERSION.SDK_INT >= 26) {
            vibrator.vibrate(VibrationEffect.createOneShot(200, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            vibrator.vibrate(200)
        }
    }
}